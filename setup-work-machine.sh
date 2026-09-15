#!/usr/bin/env bash
# setup-work-machine.sh -- one-shot install of .files and .zetta.d on an
# employer-managed Mac, running Emacs BUILT FROM SOURCE (no Homebrew
# emacs-plus), the same build as the personal daily driver.
#
#   curl -fsSLo ~/setup-work-machine.sh \
#     https://raw.githubusercontent.com/chiply/.files/main/setup-work-machine.sh
#   bash ~/setup-work-machine.sh            # or: bash ~/setup-work-machine.sh --dry-run
#
# What it does, in order (each step is skipped when already done, so the
# script can be re-run after a failure):
#   1. Xcode command-line tools (git needs them before anything else)
#   2. ~/.zshenv.local: the work profile and the gates (never overwritten)
#   3. git clone https://github.com/chiply/.files ~/.files
#   4. ~/.files/bootstrap.sh --profile work  -- Homebrew and the Brewfile
#      minus the personal list and minus emacs-plus, the dotfiles minus
#      the work manifest, no Syncthing folder, no personal LaunchAgent,
#      GNU Emacs master built from the pinned revision into
#      ~/Applications/EmacsSrc.app (45-70 min with ahead-of-time native
#      compilation; EMACS_SRC_NATIVE_COMP=yes makes it ~10 min), .zetta.d
#      cloned and templates/zetta.work.el installed as ~/.zetta.el
#   5. ~/.private.el from the work draft (never overwritten), mode 600
#   6. the gitleaks pre-commit hook in both clones
#   7. bin/zetta install under the source build (about an hour), then
#      bin/zetta doctor and bin/zetta test
#   8. what remains by hand: credentials, gh auth, the first launch
#
# Optional environment when running it:
#   GH_HOST=github.example.com   GitHub Enterprise host for the gh CLI
#   INCLUDE_SNOWFLAKE=t          the snowsql cask
#   INCLUDE_OP=t                 the 1Password app and CLI (an employer that uses it)
#   EMACS_SRC_NATIVE_COMP=yes    lazy native compilation: a much shorter Emacs build
#
# Value-free: no credential, host or name of any employer is in this file.
# Design and evidence: work-profile.org and work-security-audit.org in .zetta.d.
set -euo pipefail

DRY=0; [ "${1:-}" = "--dry-run" ] && DRY=1
FILES="$HOME/.files"; ZETTA="$HOME/.zetta.d"
EMACS_APP="$HOME/Applications/EmacsSrc.app"
EMACS_BIN="$EMACS_APP/Contents/MacOS/Emacs"

say()  { printf '\n\033[1;36m== %s\033[0m\n' "$*"; }
note() { printf '   %s\n' "$*"; }
die()  { printf '\n\033[1;31m!! %s\033[0m\n' "$*" >&2; exit 1; }
run()  { if [ "$DRY" = 1 ]; then printf '   [dry-run] %s\n' "$*"; else "$@"; fi; }

[ "$(uname -s)" = Darwin ] || die "macOS only"
if [ -f "$HOME/.zshenv.local" ] && grep -q "OP_SERVICE_ACCOUNT_TOKEN" "$HOME/.zshenv.local"; then
  die "this looks like the PERSONAL machine (~/.zshenv.local holds the vault token); refusing"
fi
if [ -f "$HOME/.zshenv.local" ] && ! grep -q "DOTFILES_PROFILE=work" "$HOME/.zshenv.local"; then
  die "a ~/.zshenv.local exists without DOTFILES_PROFILE=work; add the work block by hand or move the file aside"
fi
[ "$DRY" = 1 ] && note "DRY RUN: nothing below is executed"

say "1. Xcode command-line tools"
if xcode-select -p >/dev/null 2>&1; then note "present"; else
  run xcode-select --install
  if [ "$DRY" = 0 ]; then note "waiting for the installer dialog to finish..."; until xcode-select -p >/dev/null 2>&1; do sleep 10; done; fi
fi

say "2. ~/.zshenv.local (the profile and the gates)"
if [ -f "$HOME/.zshenv.local" ]; then note "exists, left alone"; else
  if [ "$DRY" = 1 ]; then note "[dry-run] would write ~/.zshenv.local with DOTFILES_PROFILE=work, INCLUDE_EMACS_PLUS=f, INCLUDE_EMACS_SRC=t, EMACS=$EMACS_BIN"; else
    {
      echo "# work machine -- never the personal 1Password token"
      echo "export DOTFILES_PROFILE=work"
      echo "export INCLUDE_EMACS_PLUS=f          # no Homebrew Emacs: the source build alone"
      echo "export INCLUDE_EMACS_SRC=t           # build GNU Emacs master (pinned) into ~/Applications/EmacsSrc.app"
      echo "export INCLUDE_EMACS_MAC=f"
      echo "export INCLUDE_OTHER_DISTROS=f       # no Spacemacs/Doom/Prelude/Centaur"
      echo "export INCLUDE_SNOWFLAKE=${INCLUDE_SNOWFLAKE:-f}"
      echo "export INCLUDE_OP=${INCLUDE_OP:-f}"
      [ -n "${GH_HOST:-}" ] && echo "export GH_HOST=$GH_HOST"
      echo "# bin/zetta and the shell tools use the source build"
      echo "export EMACS=\"$EMACS_BIN\""
      echo "export PATH=\"$EMACS_APP/Contents/MacOS/bin:\$PATH\"   # emacsclient for the Claude Code hook"
    } > "$HOME/.zshenv.local"
    chmod 600 "$HOME/.zshenv.local"; note "written (mode 600)"
  fi
fi

say "3. Clone .files"
if [ -d "$FILES/.git" ]; then
  run git -C "$FILES" pull -q --ff-only origin main; note "present, updated: $(git -C "$FILES" rev-parse --short HEAD)"
else run git clone https://github.com/chiply/.files "$FILES"; fi

say "4. bootstrap.sh --profile work (Homebrew, dotfiles, the Emacs build, .zetta.d)"
note "about 30 minutes plus the Emacs build; one sudo prompt at the start"
if [ "$DRY" = 1 ]; then note "[dry-run] source ~/.zshenv.local && $FILES/bootstrap.sh --profile work"; else
  set +u
  # shellcheck source=/dev/null
  source "$HOME/.zshenv.local"
  set -u
  ( cd "$FILES" && ./bootstrap.sh --profile work )
fi

say "5. Checks after the bootstrap"
[ "$DRY" = 1 ] && note "[dry-run] would verify the Emacs bundle, the .zetta.d clone and the work template"
if [ "$DRY" = 0 ]; then
  [ -x "$EMACS_BIN" ] || die "no $EMACS_APP -- the Emacs build did not finish; re-run: INCLUDE_EMACS_SRC=t $FILES/install_emacs_source.sh"
  note "Emacs: $("$EMACS_BIN" --version | head -1)"
  [ -d "$ZETTA/.git" ] || die "no ~/.zetta.d clone"
  if [ ! -f "$HOME/.zetta.el" ]; then cp "$ZETTA/templates/zetta.work.el" "$HOME/.zetta.el"; fi
  grep -q "WORK profile" "$HOME/.zetta.el" || die "the ~/.zetta.el in place is not the work template; fix before installing packages"
  note "user config: $(sed -n 3p "$HOME/.zetta.el")"
  note "$(python3 "$FILES/main.py" --dry-run --profile work | tail -1)"
  [ -L "$HOME/.emacs.d/early-init.el" ] || note "no ~/.emacs.d/early-init.el link: a Finder launch would skip zetta's early-init (the shims pass --init-directory and are fine); install_emacs_distros.sh makes it"
fi

say "6. ~/.private.el (work draft; no personal vault, no mail)"
if [ -f "$HOME/.private.el" ]; then note "exists, left alone"; elif [ "$DRY" = 1 ]; then note "[dry-run] would write the draft"; else
  cat > "$HOME/.private.el" <<'PRIV'
;;; ~/.private.el -- WORK machine  -*- lexical-binding: t; -*-
;; No personal vault.  Credentials live in ~/.authinfo.gpg (or ~/.authinfo at
;; mode 600), which the `authinfo' secrets backend of ~/.zetta.el reads:
;;   machine api.github.com    login <work-login>^forge password <token>
;;   machine api.anthropic.com login apikey             password <key>
;; GitHub Enterprise: one more forge-alist row and GH_HOST for the gh CLI.
;; (with-eval-after-load 'forge
;;   (push '("github.example.com" "github.example.com/api/v3"
;;           "github.example.com" forge-github-repository) forge-alist))

;; AI: Claude is the default backend (ai.el registers nothing personal here).
(with-eval-after-load 'gptel
  (setq gptel-backend (alist-get "Claude" gptel--known-backends nil nil #'equal)))
(setq org-decorate-backend 'claude)

;; Fill in when known; the modules stay inert until then.
;; (setq zetta-jira-url  "https://<employer>.atlassian.net"
;;       zetta-jira-jqls '((:jql "assignee = currentUser() and sprint in openSprints() ORDER BY priority DESC" :limit 200 :filename "My sprint")))
;; (setq zetta-slack-teams '((:name "acme" :host "acme.slack.com" :user "me@acme.example" :default t)))
;; (setq zetta-ssh-hosts '("dev-box" "bastion"))          ; default: ~/.ssh/config's Host list
;; (setq zetta-sql-endpoint-files '("~/work/db-endpoints.el"))
;; (setq zetta-git-repos '("~/work/repo-a"))
PRIV
  chmod 600 "$HOME/.private.el"; note "written (mode 600)"
fi

say "7. The gitleaks pre-commit hook in both clones"
run git -C "$FILES" config core.hooksPath .githooks
[ "$DRY" = 1 ] || run git -C "$ZETTA" config core.hooksPath .githooks

say "8. bin/zetta install under the source build (about an hour), then doctor and test"
if [ "$DRY" = 1 ]; then note "[dry-run] EMACS=$EMACS_BIN $ZETTA/bin/zetta install; doctor; test"; else
  ( cd "$ZETTA" && EMACS="$EMACS_BIN" bin/zetta install )
  ( cd "$ZETTA" && EMACS="$EMACS_BIN" bin/zetta doctor )
  ( cd "$ZETTA" && EMACS="$EMACS_BIN" bin/zetta test )
fi

say "Done.  By hand now:"
note "1. gpg --quick-gen-key you@work.example; write ~/.authinfo.gpg (see ~/.private.el); chmod 600"
note "2. gh auth login  (GH_HOST for GitHub Enterprise); git config --global github.user <work-login>"
note "3. first launch: emacs-src-latest --zetta   (zemacs shim; ecs = emacsclient -s src)"
note "4. day-one checks: no mail glyph or Spotify row in the tab bar; M-x gptel shows Claude only;"
note "   a capture lands in ~/kb/inbox.org; M-x forge-pull in a work checkout; M-x copilot-login if seated"
note "5. bin/zetta doctor must read: Profile: work, Secrets backend: authinfo, no Mode warning"
