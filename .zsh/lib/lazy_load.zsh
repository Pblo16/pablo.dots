#-----------------------------------------
# LAZY LOADING DE HERRAMIENTAS
#-----------------------------------------
# Este archivo contiene las funciones de lazy loading para cargar herramientas solo cuando se usan.
# Usamos funciones stub que cargan el módulo la primera vez que se ejecutan.

# Lazy loading para herramientas de desarrollo
function lg() {
  if [[ -z "$DEV_LOADED" ]]; then
    load_module "$ZSH_TOOLS_DIR/dev.zsh"
    export DEV_LOADED=1
  fi
  unfunction lg
  lg "$@"
}
function pg() {
  if [[ -z "$DEV_LOADED" ]]; then
    load_module "$ZSH_TOOLS_DIR/dev.zsh"
    export DEV_LOADED=1
  fi
  unfunction pg
  pg "$@"
}
function my() {
  if [[ -z "$DEV_LOADED" ]]; then
    load_module "$ZSH_TOOLS_DIR/dev.zsh"
    export DEV_LOADED=1
  fi
  unfunction my
  my "$@"
}

# Lazy loading para PHP/Laravel
function php() {
  if [[ -z "$PHP_LOADED" ]]; then
    load_module "$ZSH_TOOLS_DIR/php.zsh"
    export PHP_LOADED=1
  fi
  unfunction php
  php "$@"
}
function composer() {
  if [[ -z "$PHP_LOADED" ]]; then
    load_module "$ZSH_TOOLS_DIR/php.zsh"
    export PHP_LOADED=1
  fi
  unfunction composer
  composer "$@"
}
function pa() {
  if [[ -z "$PHP_LOADED" ]]; then
    load_module "$ZSH_TOOLS_DIR/php.zsh"
    export PHP_LOADED=1
  fi
  unfunction pa
  pa "$@"
}
function sail() {
  if [[ -z "$PHP_LOADED" ]]; then
    load_module "$ZSH_TOOLS_DIR/php.zsh"
    export PHP_LOADED=1
  fi
  unfunction sail
  sail "$@"
}
function pint() {
  if [[ -z "$PHP_LOADED" ]]; then
    load_module "$ZSH_TOOLS_DIR/php.zsh"
    export PHP_LOADED=1
  fi
  unfunction pint
  pint "$@"
}

# Lazy loading para Node.js
function node() {
  if [[ -z "$NODE_LOADED" ]]; then
    load_module "$ZSH_TOOLS_DIR/node.zsh"
    export NODE_LOADED=1
  fi
  unfunction node
  node "$@"
}
function npm() {
  if [[ -z "$NODE_LOADED" ]]; then
    load_module "$ZSH_TOOLS_DIR/node.zsh"
    export NODE_LOADED=1
  fi
  unfunction npm
  npm "$@"
}
function pnpm() {
  if [[ -z "$NODE_LOADED" ]]; then
    load_module "$ZSH_TOOLS_DIR/node.zsh"
    export NODE_LOADED=1
  fi
  unfunction pnpm
  pnpm "$@"
}
function bun() {
  if [[ -z "$NODE_LOADED" ]]; then
    load_module "$ZSH_TOOLS_DIR/node.zsh"
    export NODE_LOADED=1
  fi
  unfunction bun
  bun "$@"
}
function pn() {
  if [[ -z "$NODE_LOADED" ]]; then
    load_module "$ZSH_TOOLS_DIR/node.zsh"
    export NODE_LOADED=1
  fi
  unfunction pn
  pn "$@"
}
function nr() {
  if [[ -z "$NODE_LOADED" ]]; then
    load_module "$ZSH_TOOLS_DIR/node.zsh"
    export NODE_LOADED=1
  fi
  unfunction nr
  nr "$@"
}
function nx() {
  if [[ -z "$NODE_LOADED" ]]; then
    load_module "$ZSH_TOOLS_DIR/node.zsh"
    export NODE_LOADED=1
  fi
  unfunction nx
  nx "$@"
}
function fnm() {
  if [[ -z "$NODE_LOADED" ]]; then
    load_module "$ZSH_TOOLS_DIR/node.zsh"
    export NODE_LOADED=1
  fi
  unfunction fnm
  fnm "$@"
}

# Lazy loading para Go
function go() {
  if [[ -z "$GO_LOADED" ]]; then
    load_module "$ZSH_TOOLS_DIR/golang.zsh"
    export GO_LOADED=1
  fi
  unfunction go
  go "$@"
}

# Lazy loading para Docker
function docker() {
  if [[ -z "$DOCKER_LOADED" ]]; then
    load_module "$ZSH_TOOLS_DIR/docker.zsh"
    export DOCKER_LOADED=1
  fi
  unfunction docker
  docker "$@"
}

# Atuin lazy loading
function atuin_lazy_load() {
  if command -v atuin >/dev/null 2>&1 && [[ -z "$ATUIN_INIT" ]]; then
    if [[ -f "$HOME/.atuin/bin/env" ]]; then
      . "$HOME/.atuin/bin/env"
      eval "$(atuin init zsh)"
    elif [[ -d "$HOME/.local/share/atuin" ]]; then
      export PATH="$HOME/.local/share/atuin:$PATH"
      eval "$(atuin init zsh)"
    else
      eval "$(atuin init zsh)"
    fi
    export ATUIN_INIT=1
    add-zsh-hook -d preexec atuin_lazy_load
  fi
}
add-zsh-hook preexec atuin_lazy_load

# Agrega tus lazy loads personalizados aquí
# Ejemplo:
# function lazy_load_custom() {
#   if [[ "$1" =~ ^(comando) ]]; then
#     # Cargar módulo o configurar
#     add-zsh-hook -d preexec lazy_load_custom
#   fi
# }
# add-zsh-hook preexec lazy_load_custom