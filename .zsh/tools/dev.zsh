#-----------------------------------------
# CONFIGURACIÓN PARA ENTORNOS DE DESARROLLO
#-----------------------------------------

#========= NODE.JS Y JAVASCRIPT =========
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
alias nr="npm run"
alias nx="npx"

#========= DOCKER Y CONTENEDORES =========
# Alias para Docker
alias dk='Docker\ Desktop.exe'    # Para WSL
alias dc="docker compose"
alias dps="docker ps"
alias dex="docker exec -it"
alias dlog="docker logs"

#========= GO =========
if command -v go &>/dev/null; then
  export GOPATH="$HOME/gocode"
  append_path "$GOPATH/bin"
fi

#========= PHP/LARAVEL =========
# Agregar Composer al PATH
append_path "$HOME/.config/composer/vendor/bin"
append_path "$HOME/.config/herd-lite/bin"

# Aliases para Laravel
alias sail='sh $([ -f sail ] && echo sail || echo vendor/bin/sail)'  # Ejecutar Laravel Sail
alias pint='php $([ -f pint ] && echo pint || echo vendor/bin/pint)' # Ejecutar Laravel Pint
alias pa="php artisan"

#========= HERRAMIENTAS ADICIONALES =========
# Turso
append_path "$HOME/.turso"

# Otras herramientas de desarrollo
if command -v lazygit &>/dev/null; then
  alias lg="lazygit"
fi

# Utilidades de bases de datos
alias pg="psql"
alias my="mysql"
