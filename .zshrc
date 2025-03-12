# Personal Zsh configuration file. It is strongly recommended to keep all
# shell customization and configuration (including exported environment
# variables such as PATH) in this file or in files sourced from it.
#
# Documentation: https://github.com/romkatv/zsh4humans/blob/v5/README.md.
skip_global_compinit=1
autoload -Uz compinit
compinit

plugins=(git)


BREW_BIN="/home/linuxbrew/.linuxbrew/bin"

eval "$($BREW_BIN/brew shellenv)"

source $(dirname $BREW_BIN)/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
source $(dirname $BREW_BIN)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(dirname $BREW_BIN)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

WM_VAR="/$TMUX"
# change with ZELLIJ
WM_CMD="tmux"
# change with zellij

function start_if_needed() {
    if [[ $- == *i* ]] && [[ -z "${WM_VAR#/}" ]] && [[ -t 1 ]]; then
        exec $WM_CMD
    fi
}

# Directory listing aliases
alias ls='lsd'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'

# Set shell options: http://zsh.sourceforge.net/Doc/Release/Options.html.
setopt glob_dots     # no special treatment for file names with a leading dot
setopt no_auto_menu  # require an extra TAB press to open the completion menu

#-----------------------------------------
# PATH AND ENVIRONMENT CONFIGURATION
#-----------------------------------------
# Add paths to PATH variable (consolidated)
export PATH="$HOME/.config/herd-lite/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.config/composer/vendor/bin:$PATH"

# Initialize Homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Shell enhancements
eval "$(oh-my-posh init zsh --config $(brew --prefix oh-my-posh)/themes/nordtron.omp.json)"
source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
eval "$(zoxide init zsh)"

#-----------------------------------------
# PACKAGE MANAGERS
#-----------------------------------------
# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# fnm
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(XDG_RUNTIME_DIR=/tmp/run/user/$(id -u) fnm env --use-on-cd --shell zsh)"
fi



#-----------------------------------------
# TOOLS AND UTILITIES
#-----------------------------------------
# Atuin shell history
. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"

# Load Angular CLI autocompletion
source <(ng completion script)

# Turso
export PATH="$PATH:$HOME/.turso"

# Laravel aliases
alias sail='sh $([ -f sail ] && echo sail || echo vendor/bin/sail)'
alias pint='php $([ -f pint ] && echo pint || echo vendor/bin/pint)'

