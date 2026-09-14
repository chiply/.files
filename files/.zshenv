# Source machine-local secrets and the profile switch (not tracked in git):
# DOTFILES_PROFILE=work on an employer-managed machine, and never the
# personal 1Password token there.  README.md, "Profiles".
[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local
export DOTFILES_PROFILE="${DOTFILES_PROFILE:-personal}"
# `brew' drops every non-HOMEBREW_* variable before it reads the Brewfile.
export HOMEBREW_DOTFILES_PROFILE="$DOTFILES_PROFILE"

# Linode CLI token (via 1Password) — lazy-loaded on first use to avoid
# adding ~500ms to every shell startup.  Personal infrastructure: not
# defined on the work profile.
if [[ "$DOTFILES_PROFILE" != work ]]; then
  linode-cli() {
    if [[ -z "$LINODE_CLI_TOKEN" ]]; then
      export LINODE_CLI_TOKEN="$(op read 'op://Dev/Linode/token' 2>/dev/null)"
    fi
    unfunction linode-cli 2>/dev/null
    command linode-cli "$@"
  }
fi
