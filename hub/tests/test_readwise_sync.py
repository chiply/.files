"""Unit tests for readwise_sync.py rendering and mapping logic.

Stdlib only (unittest); no network. Run: python3 -m unittest discover -s hub/tests
"""
import importlib.util
import os
import tempfile
import unittest

_HERE = os.path.dirname(os.path.abspath(__file__))
_spec = importlib.util.spec_from_file_location(
    "readwise_sync", os.path.join(_HERE, "..", "bin", "readwise_sync.py")
)
rs = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(rs)

BOOK = {
    "user_book_id": 42,
    "title": "Test Book: A Journey",
    "readable_title": "Test Book: A Journey",
    "author": "Testy McTest",
    "category": "podcasts",
    "source": "snipd",
    "source_url": "https://example.com/ep",
    "readwise_url": "https://readwise.io/bookreview/42",
    "summary": "An auto-generated summary of the episode.",
    "highlights": [
        {
            "id": 1,
            "text": "First Line Title\n\nBody line here\n* looks like an org heading",
            "note": "a note",
            "highlighted_at": "2024-01-02T03:04:05Z",
            "location": 374,
            "location_type": "time_offset",
            "tags": [{"name": "tag1"}],
        },
        {
            "id": 2,
            "text": "y" * 200,
            "highlighted_at": None,
            "created_at": "2023-08-12T19:19:39Z",
            "location": 1,
            "tags": [],
        },
    ],
}


class HeadingTests(unittest.TestCase):
    def test_first_line_becomes_heading(self):
        self.assertEqual(
            rs.org_safe_heading(BOOK["highlights"][0]["text"]), "First Line Title"
        )

    def test_long_first_line_truncates_with_ellipsis(self):
        h = rs.org_safe_heading("y" * 200)
        self.assertLessEqual(len(h), rs.HEADING_LEN + 1)
        self.assertTrue(h.endswith("…"))

    def test_leading_asterisks_stripped(self):
        self.assertFalse(rs.org_safe_heading("*** sneaky").startswith("*"))

    def test_empty_text_placeholder(self):
        self.assertEqual(rs.org_safe_heading(""), "(empty highlight)")


class BodyTests(unittest.TestCase):
    def test_body_indented_so_asterisks_are_inert(self):
        body = rs.org_safe_body(BOOK["highlights"][0]["text"])
        for line in body.splitlines():
            self.assertTrue(line.startswith("  "))


class SubdirTests(unittest.TestCase):
    def test_source_specific_mappings(self):
        self.assertEqual(rs.subdir_for({"source": "snipd", "category": "podcasts"}), "podcasts")
        self.assertEqual(rs.subdir_for({"source": "kindle", "category": "books"}), "kindle")
        self.assertEqual(rs.subdir_for({"source": "command", "category": "articles"}), "command")
        self.assertEqual(rs.subdir_for({"source": "voicenotes", "category": "articles"}), "voicenotes")
        self.assertEqual(rs.subdir_for({"source": "supplemental", "category": "supplementals"}), "supplementals")

    def test_category_fallbacks(self):
        self.assertEqual(rs.subdir_for({"source": "reader", "category": "articles"}), "web")
        self.assertEqual(rs.subdir_for({"source": "web_clipper", "category": "articles"}), "web")
        self.assertEqual(rs.subdir_for({"source": "", "category": "books"}), "kindle")

    def test_unknown_category_gets_slug_dir(self):
        self.assertEqual(rs.subdir_for({"source": "new", "category": "Weird Thing!"}), "weird-thing")

    def test_author_dir(self):
        self.assertEqual(rs.author_dir({"author": "The Knowledge Project with Shane Parrish"}),
                         "the-knowledge-project-with-shane-parrish")
        self.assertEqual(rs.author_dir({"author": None}), "unknown")
        self.assertEqual(rs.author_dir({}), "unknown")


class RenderTests(unittest.TestCase):
    def setUp(self):
        self.out = rs.render_org(BOOK)

    def test_dates_highlighted_and_saved_fallback(self):
        self.assertIn(":HIGHLIGHTED: [2024-01-02]", self.out)
        self.assertIn(":SAVED: [2023-08-12]", self.out)

    def test_metadata_present(self):
        self.assertIn("#+title: Test Book: A Journey", self.out)
        self.assertIn("#+filetags: :readwise:podcasts:", self.out)
        self.assertIn("#+readwise_id: 42", self.out)
        self.assertIn(":TAGS: tag1", self.out)

    def test_no_structure_leak(self):
        top_level = [l for l in self.out.splitlines() if l.startswith("* ")]
        self.assertEqual(top_level, ["* Summary", "* Highlights"])

    def test_readwise_url_and_summary(self):
        self.assertIn("#+readwise_url: https://readwise.io/bookreview/42", self.out)
        self.assertIn("* Summary", self.out)
        self.assertIn("  An auto-generated summary", self.out)

    def test_time_offset_rendered_as_timestamp(self):
        self.assertIn(":AT: 6:14", self.out)          # 374s
        self.assertNotIn(":LOCATION: 374", self.out)
        self.assertIn(":LOCATION: 1", self.out)        # plain location untouched

    def test_time_offset_with_hours(self):
        h = dict(BOOK["highlights"][0], location=3725)  # 1:02:05
        out = rs.render_org(dict(BOOK, highlights=[h]))
        self.assertIn(":AT: 1:02:05", out)


class PlanTests(unittest.TestCase):
    def test_unique_title_gets_clean_name(self):
        plan = rs.plan_paths([BOOK])
        self.assertEqual(plan[42], os.path.join("podcasts", "testy-mctest",
                                                "test-book-a-journey.org"))

    def test_twins_both_get_id_suffix(self):
        twin = dict(BOOK, user_book_id=43)
        plan = rs.plan_paths([BOOK, twin])
        self.assertEqual(plan[42], os.path.join("podcasts", "testy-mctest",
                                                "test-book-a-journey-42.org"))
        self.assertEqual(plan[43], os.path.join("podcasts", "testy-mctest",
                                                "test-book-a-journey-43.org"))


class WriteTests(unittest.TestCase):
    def test_write_book_is_idempotent(self):
        with tempfile.TemporaryDirectory() as tmp:
            rel = rs.plan_paths([BOOK])[42]
            self.assertTrue(rs.write_book(tmp, BOOK, rel))
            self.assertTrue(os.path.exists(os.path.join(tmp, rel)))
            self.assertFalse(rs.write_book(tmp, BOOK, rel))  # unchanged -> no write


class CleanupTests(unittest.TestCase):
    def test_orphan_org_removed_others_untouched(self):
        with tempfile.TemporaryDirectory() as tmp:
            rel = rs.plan_paths([BOOK])[42]
            rs.write_book(tmp, BOOK, rel)
            stray_org = os.path.join(tmp, "podcasts", "old-scheme", "stale.org")
            keep_txt = os.path.join(tmp, "podcasts", "old-scheme", "notes.txt")
            os.makedirs(os.path.dirname(stray_org))
            open(stray_org, "w").close()
            open(keep_txt, "w").close()
            removed = rs.cleanup_orphans(tmp, {rel})
            self.assertEqual(removed, 1)
            self.assertFalse(os.path.exists(stray_org))
            self.assertTrue(os.path.exists(keep_txt))      # non-.org survives
            self.assertTrue(os.path.exists(os.path.join(tmp, rel)))

    def test_empty_dirs_pruned(self):
        with tempfile.TemporaryDirectory() as tmp:
            rel = rs.plan_paths([BOOK])[42]
            rs.write_book(tmp, BOOK, rel)
            stray = os.path.join(tmp, "web", "gone-author", "stale.org")
            os.makedirs(os.path.dirname(stray))
            open(stray, "w").close()
            rs.cleanup_orphans(tmp, {rel})
            self.assertFalse(os.path.exists(os.path.join(tmp, "web")))


class SlugTests(unittest.TestCase):
    def test_slugify(self):
        self.assertEqual(rs.slugify("Hello, World!"), "hello-world")
        self.assertEqual(rs.slugify(""), "untitled")
        self.assertEqual(rs.slugify(None), "untitled")


if __name__ == "__main__":
    unittest.main()
