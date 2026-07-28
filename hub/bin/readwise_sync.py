#!/usr/bin/env python3
"""Mirror Readwise highlights into org files (one file per book/source).

Stdlib only. Designed to run hourly from a systemd timer on the hub.

FULL-MIRROR mode: every run fetches the complete library (~9 requests
at 843 books — trivially within rate limits) and makes the output tree
exactly match it. Because each run sees everything, filename collisions
are resolved globally: books with a unique source/author/title slug get
clean names; only true twins carry an id suffix. Orphaned .org files
(renamed titles, deleted books, scheme changes) are removed and empty
dirs pruned — the readwise/ tree is strictly machine-owned. Non-.org
files are never touched. Files are written only when content changed,
so an unchanged library produces zero writes.
"""
import argparse
import datetime
import json
import os
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

API = "https://readwise.io/api/v2/export/"
TOKEN_PATH = os.path.expanduser("~/.config/readwise/token")
STATE_PATH = os.path.expanduser("~/.local/state/readwise-sync/last_sync")
OUT_DIR = os.path.expanduser("~/kb/readwise")
HEADING_LEN = 70


def log(msg):
    print(msg, file=sys.stderr)


def load_token():
    tok = os.environ.get("READWISE_TOKEN")
    if not tok and os.path.exists(TOKEN_PATH):
        with open(TOKEN_PATH) as f:
            tok = f.read().strip()
    return tok


def fetch_page(token, params):
    url = API + "?" + urllib.parse.urlencode(params)
    req = urllib.request.Request(url, headers={"Authorization": f"Token {token}"})
    while True:
        try:
            with urllib.request.urlopen(req, timeout=60) as resp:
                return json.load(resp)
        except urllib.error.HTTPError as e:
            if e.code == 429:
                wait = int(e.headers.get("Retry-After", "30"))
                log(f"rate limited; sleeping {wait}s")
                time.sleep(wait)
                continue
            raise


def fetch_books(token, updated_after=None, ids=None):
    """Yield book dicts across all pages."""
    params = {}
    if updated_after:
        params["updatedAfter"] = updated_after
    if ids:
        params["ids"] = ",".join(str(i) for i in ids)
    cursor = None
    while True:
        page_params = dict(params)
        if cursor:
            page_params["pageCursor"] = cursor
        data = fetch_page(token, page_params)
        yield from data.get("results", [])
        cursor = data.get("nextPageCursor")
        if not cursor:
            return


def slugify(text, maxlen=60):
    slug = re.sub(r"[^a-z0-9]+", "-", (text or "untitled").lower()).strip("-")
    return slug[:maxlen] or "untitled"


# Subfolder per origin. Specific sources win; category is the fallback
# (probed against the live library 2026-07-27: snipd, reader, voicenotes,
# mobile_share, command, kindle, supplemental, web_clipper).
SOURCE_DIRS = {
    "snipd": "podcasts",
    "kindle": "kindle",
    "command": "command",
    "voicenotes": "voicenotes",
    "supplemental": "supplementals",
}
CATEGORY_DIRS = {
    "podcasts": "podcasts",
    "articles": "web",
    "books": "kindle",
    "tweets": "tweets",
    "supplementals": "supplementals",
}


def subdir_for(book):
    src = (book.get("source") or "").lower()
    if src in SOURCE_DIRS:
        return SOURCE_DIRS[src]
    cat = (book.get("category") or "").lower()
    return CATEGORY_DIRS.get(cat, slugify(cat or "other", 20))


def author_dir(book):
    return slugify(book.get("author") or "unknown", 50)


def org_safe_heading(text):
    # First non-empty line: for Snipd/article highlights it's a natural
    # title; whole-text collapse glued it to the body's first bullet.
    lines = [l.strip() for l in (text or "").splitlines() if l.strip()]
    line = " ".join(lines[0].split()) if lines else ""
    line = line.lstrip("*").strip()
    if len(line) > HEADING_LEN:
        line = line[:HEADING_LEN].rstrip() + "…"
    return line or "(empty highlight)"


def org_safe_body(text):
    # Indent body lines: an org heading must start at column 0, so
    # indentation makes highlight text structurally inert.
    return "\n".join("  " + line for line in (text or "").splitlines())


def sort_key(h):
    return (
        h.get("highlighted_at") or h.get("created_at") or "",
        h.get("location") or 0,
        h.get("id") or 0,
    )


def render_org(book):
    lines = []
    title = book.get("readable_title") or book.get("title") or "Untitled"
    category = slugify(book.get("category") or "uncategorized", 20).replace("-", "")
    lines.append(f"#+title: {title}")
    if book.get("author"):
        lines.append(f"#+author: {book['author']}")
    lines.append(f"#+filetags: :readwise:{category}:")
    lines.append(f"#+readwise_id: {book.get('user_book_id')}")
    if book.get("source_url"):
        lines.append(f"#+source: {book['source_url']}")
    lines.append("")
    if book.get("document_note"):
        lines.append("* Document note")
        lines.append(org_safe_body(book["document_note"]))
        lines.append("")
    lines.append("* Highlights")
    for h in sorted(book.get("highlights", []), key=sort_key):
        lines.append(f"** {org_safe_heading(h.get('text'))}")
        props = [":PROPERTIES:", f":READWISE_ID: {h.get('id')}"]
        if h.get("highlighted_at"):
            props.append(f":HIGHLIGHTED: [{h['highlighted_at'][:10]}]")
        elif h.get("created_at"):
            # auto-imported highlights (supplementals) have no
            # highlighted_at; date them by when they entered the library
            props.append(f":SAVED: [{h['created_at'][:10]}]")
        if h.get("location") is not None:
            props.append(f":LOCATION: {h['location']}")
        tags = [t["name"] for t in h.get("tags") or []]
        if tags:
            props.append(f":TAGS: {' '.join(tags)}")
        if h.get("url"):
            props.append(f":URL: {h['url']}")
        props.append(":END:")
        lines.extend(props)
        lines.append(org_safe_body(h.get("text")))
        if h.get("note"):
            lines.append("")
            lines.append("  Note:")
            lines.append(org_safe_body(h["note"]))
        lines.append("")
    return "\n".join(lines).rstrip() + "\n"


def plan_paths(books):
    """Map user_book_id -> relative output path, resolving collisions
    globally: unique slugs get clean names, twins get an id suffix."""
    groups = {}
    for b in books:
        key = (subdir_for(b), author_dir(b),
               slugify(b.get("readable_title") or b.get("title")))
        groups.setdefault(key, []).append(b)
    plan = {}
    for (src, auth, slug), members in groups.items():
        for m in members:
            fname = (f"{slug}.org" if len(members) == 1
                     else f"{slug}-{m['user_book_id']}.org")
            plan[m["user_book_id"]] = os.path.join(src, auth, fname)
    return plan


def write_book(out_dir, book, relpath):
    path = os.path.join(out_dir, relpath)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    content = render_org(book)
    if os.path.exists(path):
        with open(path) as f:
            if f.read() == content:
                return False
    with open(path, "w") as f:
        f.write(content)
    return True


def cleanup_orphans(out_dir, expected_relpaths):
    """Remove .org files not in the expected set; prune empty dirs.
    Never touches non-.org files."""
    removed = 0
    for root, _dirs, files in os.walk(out_dir, topdown=False):
        for f in files:
            if f.endswith(".org"):
                rel = os.path.relpath(os.path.join(root, f), out_dir)
                if rel not in expected_relpaths:
                    os.remove(os.path.join(root, f))
                    removed += 1
        if root != out_dir and not os.listdir(root):
            os.rmdir(root)
    return removed


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--output", default=OUT_DIR, help="org output directory")
    ap.add_argument("--state", default=STATE_PATH,
                    help="last-run timestamp file (informational)")
    ap.add_argument("--full", action="store_true",
                    help="kept for compatibility; every run is a full mirror")
    args = ap.parse_args()

    token = load_token()
    if not token:
        # Exit 0 so the systemd timer stays green until the token is placed.
        log(f"no token in $READWISE_TOKEN or {TOKEN_PATH}; skipping")
        return 0

    os.makedirs(args.output, exist_ok=True)
    os.makedirs(os.path.dirname(args.state), exist_ok=True)

    run_started = (
        datetime.datetime.now(datetime.timezone.utc)
        .replace(microsecond=0)
        .isoformat()
    )

    books = list(fetch_books(token))
    plan = plan_paths(books)
    written = sum(
        write_book(args.output, b, plan[b["user_book_id"]]) for b in books
    )
    removed = cleanup_orphans(args.output, set(plan.values()))

    with open(args.state, "w") as f:
        f.write(run_started + "\n")
    log(f"{len(books)} book(s); {written} written, {removed} orphan(s) removed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
