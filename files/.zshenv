# Source machine-local secrets and the profile switch (not tracked in git):
# DOTFILES_PROFILE=work on an employer-managed machine, and never the
# personal 1Password token there.  README.md, "Profiles".
[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local
export DOTFILES_PROFILE="${DOTFILES_PROFILE:-personal}"
# `brew' drops every non-HOMEBREW_* variable before it reads the Brewfile.
export HOMEBREW_DOTFILES_PROFILE="$DOTFILES_PROFILE"

# A UTF-8 locale when nothing upstream supplied one.  Nothing else here sets
# it: it has always arrived from the terminal, which derives it from the
# macOS language and region -- and sshd, launchd and a region the system has
# no locale for all leave it unset.  tmux reads exactly these three variables
# to decide whether a client is UTF-8, and one that is not gets `_' in place
# of every non-ASCII cell: the status bar icons, and every glyph in a pane.
# A value from ~/.zshenv.local (sourced above) wins.
if [[ -z "${LC_ALL:-}${LC_CTYPE:-}${LANG:-}" ]]; then
  export LANG=en_US.UTF-8
fi

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
