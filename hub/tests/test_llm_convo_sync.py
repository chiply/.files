"""Unit tests for llm_convo_sync.py: turbo-stream decode + rendering.

The test encoder mirrors the production decoder (interned value array,
objects as {"_keyidx": validx}), so parse_share_html is exercised
against a faithfully fabricated share page. Stdlib only, no network.
"""
import importlib.util
import json
import os
import tempfile
import unittest

_HERE = os.path.dirname(os.path.abspath(__file__))
_spec = importlib.util.spec_from_file_location(
    "llm_convo_sync", os.path.join(_HERE, "..", "bin", "llm_convo_sync.py"))
lc = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(lc)


def encode(obj, values):
    """Intern OBJ into VALUES turbo-stream-style; return its index."""
    if isinstance(obj, dict):
        idx = len(values)
        values.append(None)  # reserve
        values[idx] = {f"_{encode(k, values)}": encode(v, values)
                       for k, v in obj.items()}
        return idx
    if isinstance(obj, list):
        idx = len(values)
        values.append(None)
        values[idx] = [encode(e, values) for e in obj]
        return idx
    values.append(obj)
    return len(values) - 1


def make_share_html(data):
    root = {"loaderData": {"routes/share": {"serverResponse": {"data": data}}},
            "actionData": None, "errors": None}
    values = []
    encode(root, values)
    payload = json.dumps(json.dumps(values))
    return (f"<html><script>window.__reactRouterContext.streamController"
            f".enqueue({payload});</script></html>")


def msg(role, text=None, parts=None, ctype="text"):
    content = {"content_type": ctype}
    if parts is not None:
        content["parts"] = parts
    elif text is not None:
        content["parts"] = [text]
    return {"message": {"author": {"role": role}, "content": content}}


DATA = {
    "title": "Test: A Chat",
    "conversation_id": "conv-123",
    "default_model_slug": "gpt-x",
    "linear_conversation": [
        msg("system", "system prompt"),
        msg("user", "hello there"),
        msg("assistant", parts=[{"content_type": "audio_transcription",
                                 "text": "Mm-hmm."}],
            ctype="multimodal_text"),
        msg("assistant", "* markdown bullet reply"),
        msg("assistant", "", ctype="model_editable_context"),
        msg("user", "second question"),
    ],
}


class DecodeParseTests(unittest.TestCase):
    def setUp(self):
        self.convo = lc.parse_share_html(make_share_html(DATA))

    def test_title_model_id(self):
        self.assertEqual(self.convo["title"], "Test: A Chat")
        self.assertEqual(self.convo["model"], "gpt-x")
        self.assertEqual(self.convo["id"], "conv-123")

    def test_system_and_skipped_types_dropped(self):
        roles = [r for r, _ in self.convo["messages"]]
        self.assertNotIn("system", roles)

    def test_consecutive_assistant_merged(self):
        self.assertEqual(
            [r for r, _ in self.convo["messages"]],
            ["user", "assistant", "user"])
        self.assertIn("Mm-hmm.", self.convo["messages"][1][1])
        self.assertIn("markdown bullet", self.convo["messages"][1][1])


class RenderTests(unittest.TestCase):
    def test_org_structure_and_asterisk_guard(self):
        convo = lc.parse_share_html(make_share_html(DATA))
        org = lc.render_org(convo, "https://chatgpt.com/share/abc")
        self.assertIn("#+title: Test: A Chat", org)
        self.assertIn("#+source: https://chatgpt.com/share/abc", org)
        headings = [l for l in org.splitlines() if l.startswith("* ")]
        self.assertEqual(headings, ["* User", "* Assistant", "* User"])
        self.assertIn(" * markdown bullet reply", org)  # guarded, not heading


class QueueTests(unittest.TestCase):
    def test_bad_url_commented_not_lost(self):
        with tempfile.TemporaryDirectory() as tmp:
            q = os.path.join(tmp, "queue.txt")
            with open(q, "w") as f:
                f.write("not-a-real-url\n# already a comment\n")
            lc.process_queue(q, tmp)
            kept = open(q).read()
            self.assertIn("# failed", kept)
            self.assertIn("not-a-real-url", kept)
            self.assertIn("# already a comment", kept)

    def test_missing_queue_ok(self):
        self.assertEqual(lc.process_queue("/nonexistent/queue.txt"), 0)


class SanitizeTests(unittest.TestCase):
    def test_sanitize(self):
        self.assertEqual(lc.sanitize('A "quoted": name?'), "A quoted- name")


if __name__ == "__main__":
    unittest.main()
