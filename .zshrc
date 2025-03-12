#=========================================================
# CONFIGURACIÓN DE ZSH PERSONALIZADA
#=========================================================

#-----------------------------------------
# CONFIGURACIÓN BÁSICA DE ZSH
#-----------------------------------------
skip_global_compinit=1
autoload -Uz compinit
compinit

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

# Turso
export PATH="$PATH:$HOME/.turso"

#-----------------------------------------
# GESTOR DE VENTANAS (TMUX/ZELLIJ)
#-----------------------------------------
# Variables para el gestor de ventanas (actualmente tmux)
WM_VAR="/$TMUX"      # Cambiar por ZELLIJ si usas zellij
WM_CMD="tmux"        # Cambiar por zellij si cambias a ese gestor

# Inicia tmux/zellij automáticamente en sesiones interactivas
function start_if_needed() {
    if [[ $- == *i* ]] && [[ -z "${WM_VAR#/}" ]] && [[ -t 1 ]]; then
        exec $WM_CMD
    fi
}

#-----------------------------------------
# MEJORAS DE COMPLETADO Y VISUALIZACIÓN
#-----------------------------------------
# Configuración de FZF y plugins relacionados
source <(fzf --zsh)
source $BREW_PREFIX/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
source $BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/dots.config/fzf-tab.plugin.zsh

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

# Alias para Laravel
alias sail='sh $([ -f sail ] && echo sail || echo vendor/bin/sail)'
alias pint='php $([ -f pint ] && echo pint || echo vendor/bin/pint)'

#-----------------------------------------
# INICIALIZACIÓN FINAL
#-----------------------------------------
# Iniciar gestor de ventanas si es necesario
start_if_needed
