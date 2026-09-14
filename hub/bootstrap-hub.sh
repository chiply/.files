#!/usr/bin/env bash
# Provision the always-on Syncthing hub on Ubuntu 24.04 (Oracle A1.Flex
# or any Debian-family VM). Idempotent: safe to re-run.
#
# Usage: scp -r ~/.files/hub <user>@<vm>:syncthing-hub && ssh <user>@<vm> 'cd syncthing-hub && ./bootstrap-hub.sh'
# Manual steps remain after this runs — they are printed at the end.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYNC_DIR="${SYNC_DIR:-$HOME/kb}"
# systemctl --user over non-interactive ssh needs this set
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

msg() { printf '\n==> %s\n' "$*"; }

msg "base packages"
sudo DEBIAN_FRONTEND=noninteractive apt-get update -y
# build-essential: the zetta config's tree-sitter grammars compile with
# a C compiler at first use.  ripgrep and fd: the config's search paths
# (consult-ripgrep, the (todo) corpus grep) call them unguarded.  The
# apt list follows the headless profile: vterm and pdf-tools are not in
# it, so cmake/libvterm/poppler stay out until one of them is.  graphviz
# is `dot' for hywiki-graph, pandoc the org exporter's converter; both
# cheap (2026-09-11 sheet).  mermaid-cli stays out: it needs node.
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
  emacs-nox tmux mosh git python3 curl ca-certificates iptables-persistent \
  build-essential ripgrep fd-find graphviz pandoc
# Ubuntu ships fd as fdfind (name clash with another package); the
# config calls it by the usual name.
mkdir -p "$HOME/.local/bin"
ln -sfn "$(command -v fdfind)" "$HOME/.local/bin/fd"

msg "UTF-8 locale (mosh-server refuses to start without a generated UTF-8 locale;"
msg "  Blink reports that as 'mosh is not installed on the server')"
if ! locale -a 2>/dev/null | grep -qi '^en_US\.utf-\?8$'; then
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y locales
  sudo locale-gen en_US.UTF-8
  sudo update-locale LANG=en_US.UTF-8
fi

msg "timezone (the agenda computes 'today' from it; Oracle images boot in UTC)"
HUB_TZ="${HUB_TZ:-America/New_York}"
if [ "$(timedatectl show -p Timezone --value)" != "$HUB_TZ" ]; then
  sudo timedatectl set-timezone "$HUB_TZ"
fi

msg "syncthing (official apt repo — distro version lags)"
if [ ! -f /etc/apt/sources.list.d/syncthing.list ]; then
  sudo mkdir -p /etc/apt/keyrings
  sudo curl -fsSL -o /etc/apt/keyrings/syncthing-archive-keyring.gpg \
    https://syncthing.net/release-key.gpg
  echo "deb [signed-by=/etc/apt/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" \
    | sudo tee /etc/apt/sources.list.d/syncthing.list >/dev/null
  sudo apt-get update -y
fi
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y syncthing

msg "tailscale"
command -v tailscale >/dev/null 2>&1 || curl -fsSL https://tailscale.com/install.sh | sh

msg "open on-host firewall for tailnet traffic (Oracle images REJECT by default)"
sudo iptables -C INPUT -i tailscale0 -j ACCEPT 2>/dev/null \
  || sudo iptables -I INPUT -i tailscale0 -j ACCEPT
sudo netfilter-persistent save

msg "directories"
mkdir -p "$SYNC_DIR" "$HOME/.local/bin" "$HOME/.config/systemd/user" \
  "$HOME/.local/state/readwise-sync" "$HOME/.config/readwise"
# Patterns live in .stignore-shared (synced to all devices); each device's
# .stignore is just an include of it, so ignores can never drift.
if [ ! -f "$SYNC_DIR/.stignore-shared" ]; then
  cp "$REPO_DIR/seed/stignore-shared" "$SYNC_DIR/.stignore-shared"
fi
if [ ! -f "$SYNC_DIR/.stignore" ]; then
  echo "#include .stignore-shared" > "$SYNC_DIR/.stignore"
fi

msg "scripts and systemd user units"
install -m 0755 "$REPO_DIR/bin/readwise_sync.py" "$HOME/.local/bin/readwise_sync.py"
install -m 0755 "$REPO_DIR/bin/llm_convo_sync.py" "$HOME/.local/bin/llm_convo_sync.py"
install -m 0755 "$REPO_DIR/bin/notes-autocommit.sh" "$HOME/.local/bin/notes-autocommit.sh"
# Run by hand, never here: builds Emacs 31 from source (README, "Emacs
# from source").  Installed so the command is on PATH after a deploy.
install -m 0755 "$REPO_DIR/install-emacs-source.sh" "$HOME/.local/bin/install-emacs-source.sh"
cp "$REPO_DIR"/units/*.service "$REPO_DIR"/units/*.timer "$HOME/.config/systemd/user/"

msg "emacs: zetta (the daily-driver config, headless profile)"
# Clone once; never pull here.  Updates are a deliberate step (README,
# "Updating zetta"): git pull, a warm `bin/zetta build', then a restart
# when no editing session is live.
ZETTA_DIR="$HOME/.zetta.d"
if [ ! -d "$ZETTA_DIR/.git" ]; then
  git clone --quiet https://github.com/chiply/.zetta.d "$ZETTA_DIR"
fi
# The profile must be in place BEFORE anything loads init.el: bin/zetta
# substitutes the full-profile example when ~/.zetta.el is missing, and
# that profile wants a window system, SVG and a toolchain this box does
# not have.  Never overwritten -- local edits to it are the owner's.
if [ ! -f "$HOME/.zetta.el" ] && [ -f "$ZETTA_DIR/templates/zetta.headless.el" ]; then
  cp "$ZETTA_DIR/templates/zetta.headless.el" "$HOME/.zetta.el"
fi
if [ ! -d "$ZETTA_DIR/elpaca/builds" ]; then
  echo "    zetta is cloned but NOT built: emacs.service stays skipped until"
  echo "    the cold build has run (manual step below)."
fi

msg "emacs: lean fallback init + tmux + shell config"
# The lean init stays installed for emacs-lean.service (not enabled):
# the editor to start by hand when zetta is broken.
mkdir -p "$HOME/.emacs.d/backups" "$HOME/.emacs.d/autosaves"
cp "$REPO_DIR/emacs/init.el" "$HOME/.emacs.d/init.el"
cp "$REPO_DIR/tmux.conf" "$HOME/.tmux.conf"
# shell config is a deployed file + a one-line source hook, so alias
# updates propagate on every hub-deploy (an append-once block wouldn't)
install -m 0644 "$REPO_DIR/bashrc-additions.sh" "$HOME/.kb-hub-shell.sh"
if ! grep -q "kb-hub-shell" "$HOME/.bashrc"; then
  # shellcheck disable=SC2016  # $HOME is meant to expand at source time
  printf '\n# kb-hub-shell: aliases + tmux auto-attach (deployed file)\n[ -f "$HOME/.kb-hub-shell.sh" ] && . "$HOME/.kb-hub-shell.sh"\n' >> "$HOME/.bashrc"
fi

msg "git timeline repo (hub only; .git is in .stignore so it never syncs)"
if [ ! -d "$SYNC_DIR/.git" ]; then
  git -C "$SYNC_DIR" init -b main
fi
# fresh machines have no git identity; scope one to this repo
git -C "$SYNC_DIR" config user.name "kb-hub"
git -C "$SYNC_DIR" config user.email "hub@localhost"
if ! git -C "$SYNC_DIR" rev-parse HEAD >/dev/null 2>&1; then
  git -C "$SYNC_DIR" add -A
  git -C "$SYNC_DIR" commit -qm "initial snapshot" --allow-empty
fi

msg "services"
sudo loginctl enable-linger "$USER"          # user units run without a login session
sudo systemctl enable --now "syncthing@$USER"
systemctl --user daemon-reload
systemctl --user enable --now emacs.service
systemctl --user enable --now readwise-sync.timer notes-git.timer llm-convo-sync.timer

msg "done — remaining MANUAL steps"
cat <<'EOF'
1. Tailscale:      sudo tailscale up --ssh     (authenticate in browser)
2. Readwise token: paste it into ~/.config/readwise/token && chmod 600 the file
                   (get it at https://readwise.io/access_token)
3. First pull:     ~/.local/bin/readwise_sync.py --full
4. Pair devices:   ssh -L 8384:127.0.0.1:8384 <hub>, open http://localhost:8384
                   - Actions > Show ID; add hub on each device (use tailnet MagicDNS
                     name as address: tcp://<hub-name>:22000)
                   - share SYNC_DIR as folder id "kb"
                   - on the HUB folder settings: File Versioning > Staggered
5. If systemctl --user says "Failed to connect to bus": log out/in once
   (linger was just enabled), or export XDG_RUNTIME_DIR=/run/user/$(id -u).
6. Emacs config deploys DO NOT auto-restart the daemon (that would kill
   live editing sessions). Apply when convenient:
   systemctl --user restart emacs
7. zetta, first time only (hours, unattended; see README "Zetta on the hub"):
   - ~/.private.el: create it by hand; a single ";;" line is enough
     (the headless profile sets auth-sources to nil).
   - cold build, in a tmux window:
       nohup ~/.zetta.d/bin/zetta build > ~/zetta-build.log 2>&1 &
     done when the log has ZETTA-OK and no ELPACA-FAILED line.
   - seed per-machine state once the daemon is up:
       emacsclient --eval '(org-id-update-id-locations (directory-files-recursively "~/kb" "\\.org\\'"'"'"))'
       emacsclient --eval '(dolist (l (mapcar (quote car) treesit-language-source-alist)) (treesit-install-language-grammar l))'
   - then: systemctl --user restart emacs
   Until the build exists, emacs.service is skipped (ConditionPathExists);
   start the lean editor meanwhile: systemctl --user start emacs-lean
   and reach it with emacsclient -s lean -t.
EOF
