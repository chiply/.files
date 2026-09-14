#!/usr/bin/env python3
"""Symlink every file under files/ to the matching path under $HOME.

    python3 main.py [--dry-run] [--profile personal|work]

- The profile (--profile, else DOTFILES_PROFILE, else personal) selects
  an exclude manifest, profiles/<profile>.exclude: gitignore-style globs
  relative to files/ that are never linked.  `personal' has none.
- *.example files are templates to copy by hand; they are never linked.
- A REGULAR file already at a target is moved to
  ~/.dotfiles-backup/<timestamp>/<path> before the link replaces it, so
  an MDM-provisioned ~/.zshrc is not lost silently (audit S8); an
  existing symlink is replaced as before.  A target that already
  resolves to its source -- a correct link, or a path through a linked
  parent directory such as ~/.aliases -> files/.aliases -- is left alone
  (writing a link there is how the alias files became links to
  themselves, audit S10).
- --dry-run prints the plan and changes nothing.
"""
import argparse
import datetime as dt
import fnmatch
import os
import pathlib
import shutil
import sys

REPO = pathlib.Path(__file__).resolve().parent
FILES = REPO / "files"


def read_manifest(profile):
    """Patterns from profiles/<profile>.exclude, comments and blanks dropped."""
    path = REPO / "profiles" / f"{profile}.exclude"
    if not path.exists():
        return []
    patterns = []
    for line in path.read_text().splitlines():
        line = line.split("#", 1)[0].strip()
        if line:
            patterns.append(line)
    return patterns


def excluded_by(rel, patterns):
    """The first manifest pattern matching REL (a path relative to files/)."""
    for pattern in patterns:
        if fnmatch.fnmatchcase(rel, pattern):
            return pattern
    return None


def walk_files():
    """Every file under files/, as paths relative to it, sorted."""
    rels = []
    for root, _dirs, names in os.walk(FILES):
        for name in names:
            rels.append(os.path.relpath(os.path.join(root, name), FILES))
    return sorted(rels)


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--dry-run", action="store_true", help="print the plan; change nothing")
    ap.add_argument("--profile", default=os.environ.get("DOTFILES_PROFILE", "personal"),
                    help="personal (default) or work; else $DOTFILES_PROFILE")
    args = ap.parse_args(argv)

    home = pathlib.Path(os.path.expanduser("~"))
    patterns = read_manifest(args.profile)
    stamp = dt.datetime.now().strftime("%Y%m%d-%H%M%S")
    backup_root = home / ".dotfiles-backup" / stamp
    verb = "would" if args.dry_run else "did"
    counts = {"linked": 0, "kept": 0, "relinked": 0, "backed-up": 0,
              "skipped-manifest": 0, "skipped-example": 0}

    print(f"repo: {REPO}\nprofile: {args.profile} ({len(patterns)} manifest patterns)"
          f"{' -- DRY RUN' if args.dry_run else ''}")
    for rel in walk_files():
        source = FILES / rel
        target = home / rel
        if rel.endswith(".example"):
            counts["skipped-example"] += 1
            print(f"  skip     {rel}  (example file: copy by hand)")
            continue
        pattern = excluded_by(rel, patterns)
        if pattern:
            counts["skipped-manifest"] += 1
            print(f"  skip     {rel}  (manifest: {pattern})")
            continue
        if os.path.realpath(target) == os.path.realpath(source):
            # Already this file: a symlink to it, or a path that reaches it
            # through a linked parent directory (~/.aliases -> files/.aliases).
            # In the second case the old `ln -s -f' wrote a self-referencing
            # link INTO the repo -- the alias loop of 2026-03 (audit S10).
            counts["kept"] += 1
            continue
        if target.is_symlink():
            counts["relinked"] += 1
            print(f"  relink   {rel}  (was -> {os.readlink(target)})")
            if not args.dry_run:
                target.unlink()
        elif target.exists():
            counts["backed-up"] += 1
            dest = backup_root / rel
            print(f"  backup   {rel}  -> {dest}")
            if not args.dry_run:
                dest.parent.mkdir(parents=True, exist_ok=True)
                shutil.move(str(target), str(dest))
        else:
            counts["linked"] += 1
            print(f"  link     {rel}")
        if not args.dry_run:
            target.parent.mkdir(parents=True, exist_ok=True)
            os.symlink(source, target)

    summary = ", ".join(f"{k} {v}" for k, v in counts.items())
    print(f"\n{verb}: {summary}")
    if counts["backed-up"]:
        print(f"backups {'would go' if args.dry_run else 'are'} under {backup_root}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
