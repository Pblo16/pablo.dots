#=========================================================
# CONFIGURACIÓN DE ZSH PERSONALIZADA
#=========================================================

#-----------------------------------------
# CONFIGURACIÓN BÁSICA DE ZSH
#-----------------------------------------
skip_global_compinit=1
autoload -Uz compinit
compinit
setopt interactive_comments
# Plugins nativos de ZSH
plugins=(git)

# Opciones de shell: http://zsh.sourceforge.net/Doc/Release/Options.html
setopt glob_dots     # No tratar de forma especial los archivos que comienzan con punto

#-----------------------------------------
# GESTIÓN DEL ENTORNO Y PATH
#-----------------------------------------
# Variables de entorno para Homebrew
BREW_BIN="/home/linuxbrew/.linuxbrew/bin"
BREW_PREFIX="$(dirname $BREW_BIN)"

# Inicializar Homebrew (solo necesario una vez)
eval "$($BREW_BIN/brew shellenv)"

# Configuración de PATH (consolidada)
export PATH="$HOME/.config/herd-lite/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.config/composer/vendor/bin:$PATH"

#-----------------------------------------
# GESTORES DE PAQUETES
#-----------------------------------------
# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# fnm - Fast Node Manager
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(XDG_RUNTIME_DIR=/tmp/run/user/$(id -u) fnm env --use-on-cd --shell zsh)"
fi

# bun completions
[ -s "/home/pblo/.bun/_bun" ] && source "/home/pblo/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Turso
export PATH="$PATH:$HOME/.turso"

#-----------------------------------------
# GESTOR DE VENTANAS (TMUX/ZELLIJ)
#-----------------------------------------
# Variables para el gestor de ventanas (actualmente tmux)
WM_VAR="/$TMUX"     
WM_CMD="tmux"        
# Inicia tmux/zellij automáticamente en sesiones interactivas
function start_if_needed() {
    # Si está en una sesión interactiva, no hay variable TMUX (no está en tmux) y es un terminal
    if [[ $- == *i* ]] && [[ -z "$TMUX" ]] && [[ -t 1 ]]; then
        # Intentar conectarse a sesión existente o crear una nueva si no existe
        if tmux has-session 2>/dev/null; then
            exec tmux attach
        else
            exec tmux
        fi
    fi
}

#-----------------------------------------
# MEJORAS DE COMPLETADO Y VISUALIZACIÓN
#-----------------------------------------
# Configuración de FZF y plugins relacionados
source <(fzf --zsh)
# source $BREW_PREFIX/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
source $BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh

source ~/dots.config/fzf-tab.plugin.zsh/fzf-tab.plugin.zsh
# Configuración de popup para fzf-tab
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

# Oh-my-posh para prompt personalizado
eval "$(oh-my-posh init zsh --config $(brew --prefix oh-my-posh)/themes/nordtron.omp.json)"

# Zoxide - navegación inteligente entre directorios
eval "$(zoxide init zsh)"

# Atuin - gestor de historial de shell mejorado
. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"

#-----------------------------------------
# ALIAS Y FUNCIONES
#-----------------------------------------
# Alias para listado de directorios usando lsd
alias ls='lsd'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'

# Define neovim alias 
alias n='nvim .'

# Alias para Laravel
alias sail='sh $([ -f sail ] && echo sail || echo vendor/bin/sail)'
alias pint='php $([ -f pint ] && echo pint || echo vendor/bin/pint)'

export XDG_RUNTIME_DIR="$PREFIX/tmp/"

# Function to send the current working directory to WezTerm
function __wezterm_osc7() {
  if hash wezterm 2>/dev/null; then
    # Use WezTerm's helper command to set the working directory if available
    wezterm set-working-directory 2>/dev/null && return
  fi
  # Fallback: Send the current working directory to the terminal using OSC 7
  printf "\033]7;file://%s%s\033\\" "${HOSTNAME}" "${PWD}"
}

# Hook to execute the function after every interactive command
precmd_functions+=(__wezterm_osc7)
