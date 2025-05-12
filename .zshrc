#=========================================================
# CONFIGURACIÓN DE ZSH PERSONALIZADA
#=========================================================

#-----------------------------------------
# CONFIGURACIÓN BÁSICA DE ZSH
#-----------------------------------------
skip_global_compinit=2
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
# Función helper para añadir directorios al PATH si existen
function append_path() {
  if [ -d "$1" ]; then
    [[ ":$PATH:" != *":$1:"* ]] && export PATH="$1:$PATH"
  fi
}

# Variables de entorno del sistema
export XDG_RUNTIME_DIR="$PREFIX/tmp/"  # Definir directorio de tiempo de ejecución XDG

# Configuración de PATH básico
append_path "$HOME/.local/bin"

# Variables de entorno para Homebrew - Movido al principio para que BREW_PREFIX esté disponible
BREW_BIN="/home/linuxbrew/.linuxbrew/bin"
BREW_PREFIX="$(dirname $BREW_BIN)"

# Inicializar Homebrew (solo necesario una vez)
eval "$($BREW_BIN/brew shellenv)"

#-----------------------------------------
# ALIAS Y FUNCIONES BÁSICAS
#-----------------------------------------
# Aliases para navegación y listado de directorios
# Utiliza 'lsd' como reemplazo mejorado del comando 'ls' estándar
alias ls='lsd'                    # Mostrar listado básico con lsd (alternativa moderna a ls)
alias la='ls -a'                  # Mostrar archivos y directorios ocultos (incluyendo . y ..)
alias lla='ls -la'                # Mostrar listado detallado incluyendo archivos ocultos
alias lt='ls --tree'              # Mostrar estructura de directorios en formato árbol

# Aliases para desarrollo y editores
alias n='nvim .'                  # Abrir Neovim en el directorio actual
alias pj='cd ~/Projects && ls'    # Navegar al directorio de proyectos y listar su contenido
alias vc='code --reuse-window .' # Abrir VSCode en la ventana actual para el directorio actual

#-----------------------------------------
# MEJORAS DE COMPLETADO Y VISUALIZACIÓN
#-----------------------------------------
# Configuración de FZF y plugins relacionados
source <(fzf --zsh)

# Recargar sistema de autocompletado
autoload -Uz compinit && compinit -u

# Agregar rutas adicionales para definiciones de autocompletado
fpath+=($(brew --prefix)/share/zsh/site-functions)  # Autocompletados de Homebrew
fpath+=(~/.zsh/completions)                        # Autocompletados personalizados

# Oh-my-posh para prompt personalizado
eval "$(oh-my-posh init zsh --config ~/dots.config/php.opm.json)"

# Zoxide - navegación inteligente entre directorios
eval "$(zoxide init zsh)"

# Plugins de ZSH - Verificando existencia de archivos antes de cargarlos
source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

source ~/dots.config/fzf-tab.plugin.zsh/fzf-tab.plugin.zsh
. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"

#-----------------------------------------
# GESTOR DE VENTANAS (TMUX/ZELLIJ)
#-----------------------------------------
# Variables para el gestor de ventanas (actualmente tmux)
# WM_VAR="/$TMUX"     
# WM_CMD="tmux"        
## Inicia tmux/zellij automáticamente en sesiones interactivas
# function start_if_needed() {
#     # Si está en una sesión interactiva, no hay variable TMUX (no está en tmux) y es un terminal
#     if [[ $- == *i* ]] && [[ -z "$TMUX" ]] && [[ -t 1 ]]; then
#         # Intentar conectarse a sesión existente o crear una nueva si no existe
#         if tmux has-session 2>/dev/null; then
#             exec tmux attach
#         else
#             exec tmux
#         fi
#     fi
# }

# Iniciar gestor de ventanas (tmux/zellij) si es necesario
# start_if_needed

#-----------------------------------------
# INTEGRACIÓN CON WEZTERM
#-----------------------------------------
# Función para enviar el directorio de trabajo actual a WezTerm
# Esto permite que WezTerm conozca la ubicación actual para nuevas pestañas/paneles
function __wezterm_osc7() {
  if hash wezterm 2>/dev/null; then
    # Usar el comando auxiliar de WezTerm si está disponible
    wezterm set-working-directory 2>/dev/null && return
  fi
  # Alternativa: Enviar el directorio usando el protocolo OSC 7
  printf "\033]7;file://%s%s\033\\" "${HOSTNAME}" "${PWD}"
}

# Registrar la función para ejecutarse después de cada comando interactivo
precmd_functions+=(__wezterm_osc7)

#-----------------------------------------
# HERRAMIENTAS DE DESARROLLO
#-----------------------------------------

# Alias para Docker
alias dk='Docker\ Desktop.exe'    # Iniciar Docker Desktop en WSL

#-----------------------------------------
# HERRAMIENTAS DE DESARROLLO PHP/LARAVEL
#-----------------------------------------
# Agregar Composer al PATH
append_path "$HOME/.config/composer/vendor/bin"
append_path "$HOME/.config/herd-lite/bin"

# Aliases para Laravel
alias sail='sh $([ -f sail ] && echo sail || echo vendor/bin/sail)'  # Ejecutar Laravel Sail (desde directorio raíz o vendor)
alias pint='php $([ -f pint ] && echo pint || echo vendor/bin/pint)' # Ejecutar Laravel Pint (formateador de código)

#-----------------------------------------
# GESTORES DE PAQUETES Y HERRAMIENTAS JS
#-----------------------------------------
# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
append_path "$PNPM_HOME"

# fnm - Fast Node Manager
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  append_path "$FNM_PATH"
  eval "$(XDG_RUNTIME_DIR=/tmp/run/user/$(id -u) fnm env --use-on-cd --shell zsh)"
fi

# bun completions
[ -s "/home/pblo/.bun/_bun" ] && source "/home/pblo/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
append_path "$BUN_INSTALL/bin"

# Angular CLI autocompletion
if command -v ng &> /dev/null; then
  source <(ng completion script)
fi

#-----------------------------------------
# OTRAS HERRAMIENTAS DE DESARROLLO
#-----------------------------------------
# Turso
append_path "$HOME/.turso"

# Go
export GOPATH="/home/pblo/gocode"
append_path "$GOPATH/bin"

# John the Ripper
append_path "$HOME/john/run"
