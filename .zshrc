#=========================================================
# CONFIGURACIÓN DE ZSH PERSONALIZADA
#=========================================================

# Evitar carga duplicada del sistema de completado
skip_global_compinit=1

#-----------------------------------------
# CONFIGURACIÓN BÁSICA DE ZSH
#-----------------------------------------
autoload -Uz compinit
compinit
setopt interactive_comments

# Opciones de shell
setopt glob_dots     # No tratar de forma especial los archivos que comienzan con punto

#-----------------------------------------
# CARGA DE MÓDULOS Y PLUGINS
#-----------------------------------------
# Definir rutas para módulos
ZSH_CONFIG_DIR="$HOME/.zsh"
ZSH_LIB_DIR="$ZSH_CONFIG_DIR/lib"
ZSH_TOOLS_DIR="$ZSH_CONFIG_DIR/tools"
ZSH_PLUGINS_DIR="$ZSH_CONFIG_DIR/plugins"

# Función para cargar módulos si existen
function load_module() {
  [[ -f "$1" ]] && source "$1"
}

# Cargar configuraciones base esenciales
load_module "$ZSH_LIB_DIR/path.zsh"
load_module "$ZSH_LIB_DIR/aliases.zsh"
load_module "$ZSH_LIB_DIR/functions.zsh"
load_module "$ZSH_LIB_DIR/completions.zsh"

# Inicializar Homebrew (necesario antes de cargar otras herramientas)
BREW_BIN="/home/linuxbrew/.linuxbrew/bin"
if [[ -f "$BREW_BIN/brew" ]]; then
  eval "$($BREW_BIN/brew shellenv)"
fi

# Cargar configuraciones de herramientas (orden importante)
load_module "$ZSH_TOOLS_DIR/prompt.zsh"     # Oh-my-posh
load_module "$ZSH_TOOLS_DIR/terminal.zsh"   # WezTerm, tmux
load_module "$ZSH_TOOLS_DIR/fzf.zsh"        # FZF y plugins relacionados
load_module "$ZSH_TOOLS_DIR/navigation.zsh" # Zoxide
load_module "$ZSH_TOOLS_DIR/dev.zsh"        # Herramientas de desarrollo generales
load_module "$ZSH_TOOLS_DIR/php.zsh"        # PHP/Laravel
load_module "$ZSH_TOOLS_DIR/node.zsh"       # Node.js, pnpm, fnm
load_module "$ZSH_TOOLS_DIR/golang.zsh"     # Go
load_module "$ZSH_TOOLS_DIR/docker.zsh"     # Docker

# Cargar plugins de ZSH - Verificando existencia antes de cargar
if [[ -d "$BREW_PREFIX/share" ]]; then
  source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# Cargar fzf-tab (asegurar que se carga después de otros plugins)
if [[ -d "$ZSH_PLUGINS_DIR/fzf-tab" ]]; then
  source "$ZSH_PLUGINS_DIR/fzf-tab/fzf-tab.plugin.zsh"
elif [[ -d "$HOME/dots.config/plugins/fzf-tab" ]]; then
  source "$HOME/dots.config/plugins/fzf-tab/fzf-tab.plugin.zsh"
fi

# Cargar atuin (historial de comandos)
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh)"
fi

# Cargar configuraciones personalizadas
DOTS_CONFIG_DIR="$HOME/dots.config"
[[ -f "$DOTS_CONFIG_DIR/shell/zsh_custom.zsh" ]] && source "$DOTS_CONFIG_DIR/shell/zsh_custom.zsh"
