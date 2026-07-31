#!/usr/bin/env python3
"""ChatGPT share links -> org files in ~/kb/llm-convo/.

Stdlib only. Two modes:
  llm_convo_sync.py <url> [<url>...]   convert given share links now
  llm_convo_sync.py                    process the queue file (phone path):
                                       each line a URL appended by the iOS
                                       shortcut; successes are removed,
                                       failures commented out (uncomment to
                                       retry).

Share pages embed the conversation as a react-router "turbo-stream"
payload: a flat value array where objects reference entries by index
({"_249": 909} = key values[249], value deref(909)) and lists hold index
references. We decode that graph, walk to serverResponse.data, and render
linear_conversation as * User / * Assistant sections, merging consecutive
same-role fragments (voice chats produce dozens of tiny turns).
"""
import json
import os
import re
import sys
import urllib.request

QUEUE = os.path.expanduser("~/kb/llm-convo/queue.txt")
OUT_DIR = os.path.expanduser("~/kb/llm-convo")
UA = ("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
      "AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Safari/605.1.15")
SKIP_CONTENT_TYPES = {"model_editable_context", "thoughts", "reasoning_recap"}


def log(msg):
    print(msg, file=sys.stderr)


def fetch(url):
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=60) as resp:
        return resp.read().decode("utf-8", "replace")


def decode_turbo_stream(html):
    """Return the fully-dereferenced root object of the stream payload."""
    values = []
    for m in re.finditer(r'streamController\.enqueue\("((?:[^"\\]|\\.)*)"\)',
                         html, re.S):
        inner = json.loads('"' + m.group(1) + '"')
        if re.match(r"^[A-Z]\d+:", inner):          # promise chunk: P123:[...]
            inner = inner[inner.index(":") + 1:]
        inner = inner.strip()
        if inner.startswith("["):
            values.extend(json.loads(inner))
    if not values:
        raise ValueError("no turbo-stream payload found (page format changed?)")

    def deref(ref, memo):
        if isinstance(ref, (str, float, bool)) or ref is None:
            return ref
        if ref < 0:                                  # undefined/null markers
            return None
        if ref in memo:
            return memo[ref]
        v = values[ref]
        if isinstance(v, dict):
            out = {}
            memo[ref] = out
            for k, r in v.items():
                key = values[int(k[1:])] if k.startswith("_") else k
                out[key] = deref(r, memo)
            return out
        if isinstance(v, list):
            out = []
            memo[ref] = out
            for e in v:
                out.append(deref(e, memo))
            return out
        return v

    return deref(0, {})


def part_text(part):
    if isinstance(part, str):
        return part
    if isinstance(part, dict):
        if part.get("text"):
            return part["text"]
        ct = part.get("content_type", "")
        if "image" in ct:
            return "[image]"
    return ""


def parse_share_html(html):
    """Return {id, title, model, messages: [(role, text), ...]}."""
    root = decode_turbo_stream(html)
    loader = root.get("loaderData") or {}
    data = None
    for v in loader.values():
        server = (v or {}).get("serverResponse") if isinstance(v, dict) else None
        if isinstance(server, dict) and isinstance(server.get("data"), dict):
            data = server["data"]
            break
    if data is None or "linear_conversation" not in data:
        raise ValueError("no conversation in payload (page format changed?)")

    messages = []
    for node in data["linear_conversation"]:
        msg = (node or {}).get("message") if isinstance(node, dict) else None
        if not msg:
            continue
        role = (msg.get("author") or {}).get("role")
        if role not in ("user", "assistant"):
            continue
        content = msg.get("content") or {}
        if content.get("content_type") in SKIP_CONTENT_TYPES:
            continue
        parts = content.get("parts")
        text = ("\n".join(filter(None, (part_text(p) for p in parts)))
                if parts else (content.get("text") or ""))
        text = re.sub(r"[\ue000-\uf8ff]", "", text).strip()  # citation glyphs
        if not text:
            continue
        if messages and messages[-1][0] == role:      # merge voice fragments
            messages[-1] = (role, messages[-1][1] + " " + text)
        else:
            messages.append((role, text))

    model = (data.get("default_model_slug")
             or (data.get("model") or {}).get("slug") if isinstance(
                 data.get("model"), dict) else data.get("default_model_slug"))
    return {"id": data.get("conversation_id") or "",
            "title": data.get("title") or "untitled conversation",
            "model": model,
            "messages": messages}


def sanitize(name):
    name = re.sub(r"[ \t\n]+", " ", name)
    name = re.sub(r"[\"']+", "", name)
    name = re.sub(r"[/\\:*?<>|]+", "-", name)
    return name.strip(" -")


def render_org(convo, url):
    lines = [f"#+title: {convo['title']}"]
    if convo.get("model"):
        lines.append(f"#+model: {convo['model']}")
    lines += [f"#+source: {url}", "#+filetags: :llm:convo:", ""]
    for role, text in convo["messages"]:
        lines.append("* " + ("User" if role == "user" else "Assistant"))
        # a column-0 asterisk in message text would become an org heading
        lines.append(re.sub(r"(?m)^\*", " *", text))
        lines.append("")
    return "\n".join(lines).rstrip() + "\n"


def save(url, out_dir=OUT_DIR):
    convo = parse_share_html(fetch(url))
    if not convo["messages"]:
        raise ValueError("conversation parsed but contained no messages")
    share_id = url.rstrip("/").rsplit("/", 1)[-1]
    target = os.path.join(out_dir, sanitize(convo["title"]) + ".org")
    if os.path.exists(target):
        with open(target) as f:
            head = f.read(2000)
        if share_id not in head and (convo["id"] or "zzz") not in head:
            target = os.path.join(
                out_dir, f"{sanitize(convo['title'])} -- {share_id[:8]}.org")
    os.makedirs(out_dir, exist_ok=True)
    with open(target, "w") as f:
        f.write(render_org(convo, url))
    log(f"saved: {target} ({len(convo['messages'])} messages)")
    return target


def process_queue(queue=QUEUE, out_dir=OUT_DIR):
    if not os.path.exists(queue):
        return 0
    with open(queue) as f:
        lines = f.read().splitlines()
    remaining, done = [], 0
    for line in lines:
        url = line.strip()
        if not url or url.startswith("#"):
            if line.strip():
                remaining.append(line)
            continue
        try:
            save(url, out_dir)
            done += 1
        except Exception as e:                        # noqa: BLE001
            log(f"failed: {url}: {e}")
            remaining.append(f"# failed ({e}): {url}")
    with open(queue, "w") as f:
        f.write("\n".join(remaining) + ("\n" if remaining else ""))
    if done:
        log(f"queue: {done} converted, {len(remaining)} line(s) kept")
    return 0


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("-")]
    if args:
        for url in args:
            save(url)
        return 0
    return process_queue()


if __name__ == "__main__":
    sys.exit(main())
