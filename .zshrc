#=========================================================
# CONFIGURACIÓN DE ZSH PERSONALIZADA
#=========================================================

skip_global_compinit=1

#-----------------------------------------
# CONFIGURACIÓN BÁSICA DE ZSH
#-----------------------------------------
autoload -Uz compinit
compinit -C
setopt interactive_comments
setopt glob_dots

#-----------------------------------------
# CARGA DE MÓDULOS Y PLUGINS
#-----------------------------------------
ZSH_CONFIG_DIR="$HOME/.zsh"
ZSH_LIB_DIR="$ZSH_CONFIG_DIR/lib"
ZSH_TOOLS_DIR="$ZSH_CONFIG_DIR/tools"

function load_module() {
  [[ -f "$1" ]] && source "$1"
}

load_module "$ZSH_LIB_DIR/path.zsh"
load_module "$ZSH_LIB_DIR/aliases.zsh"
load_module "$ZSH_LIB_DIR/functions.zsh"
load_module "$ZSH_LIB_DIR/completions.zsh"

# Homebrew
BREW_BIN="/home/linuxbrew/.linuxbrew/bin"
if [[ -f "$BREW_BIN/brew" ]]; then
  eval "$($BREW_BIN/brew shellenv)"
fi

# Cargar herramientas
load_module "$ZSH_TOOLS_DIR/prompt.zsh"
load_module "$ZSH_TOOLS_DIR/terminal.zsh"
load_module "$ZSH_TOOLS_DIR/fzf.zsh"
load_module "$ZSH_TOOLS_DIR/navigation.zsh"
load_module "$ZSH_TOOLS_DIR/bindings.zsh"

#-----------------------------------------
# ZINIT Y PLUGINS
#-----------------------------------------
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

zinit light "Aloxaf/fzf-tab"
zinit light "zsh-users/zsh-autosuggestions"
zinit light "zdharma-continuum/fast-syntax-highlighting"

# Cargar lazy loading
load_module "$ZSH_LIB_DIR/lazy_load.zsh"

# Config personalizada
DOTS_CONFIG_DIR="$HOME/dots.config"
[[ -f "$DOTS_CONFIG_DIR/shell/zsh_custom.zsh" ]] && source "$DOTS_CONFIG_DIR/shell/zsh_custom.zsh"
