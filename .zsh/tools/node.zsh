#-----------------------------------------
# CONFIGURACIÓN PARA NODE.JS Y JAVASCRIPT
#-----------------------------------------

# fnm - Fast Node Manager
if command -v fnm &>/dev/null; then
  FNM_PATH="$HOME/.local/share/fnm"
  append_path "$FNM_PATH"
  eval "$(XDG_RUNTIME_DIR=/tmp/run/user/$(id -u) fnm env --use-on-cd --shell zsh)"
fi

# pnpm - Package manager
export PNPM_HOME="$HOME/.local/share/pnpm"
append_path "$PNPM_HOME"

# bun
if [[ -d "$HOME/.bun" ]]; then
  export BUN_INSTALL="$HOME/.bun"
  append_path "$BUN_INSTALL/bin"
  
  # bun completions
  [[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"
fi

# Angular CLI autocompletion
if command -v ng &> /dev/null; then
  source <(ng completion script)
fi

# Alias útiles para Node.js
alias pn="pnpm"
alias nr="pnpm run"
alias nx="pnpx"