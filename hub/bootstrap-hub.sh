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
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
  emacs-nox tmux mosh git python3 curl ca-certificates iptables-persistent

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
install -m 0755 "$REPO_DIR/bin/notes-autocommit.sh" "$HOME/.local/bin/notes-autocommit.sh"
cp "$REPO_DIR"/units/*.service "$REPO_DIR"/units/*.timer "$HOME/.config/systemd/user/"

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
systemctl --user enable --now readwise-sync.timer notes-git.timer

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
EOF
