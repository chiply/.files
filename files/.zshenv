# Source machine-local secrets (not tracked in git)
[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local

# Linode CLI token (via 1Password) — lazy-loaded on first use to avoid
# adding ~500ms to every shell startup
linode-cli() {
  if [[ -z "$LINODE_CLI_TOKEN" ]]; then
    export LINODE_CLI_TOKEN="$(op read 'op://Dev/Linode/token' 2>/dev/null)"
  fi
  unfunction linode-cli 2>/dev/null
  command linode-cli "$@"
}
