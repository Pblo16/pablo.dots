#-----------------------------------------
# LAZY LOADING DE HERRAMIENTAS
#-----------------------------------------
# Este archivo contiene las funciones de lazy loading para cargar herramientas solo cuando se usan.
# Agrega tus propios lazy loads aquí siguiendo el patrón.

# Lazy loading para herramientas de desarrollo
function lazy_load_dev() {
  if [[ "$1" =~ ^(lg|pg|my) ]]; then
    load_module "$ZSH_TOOLS_DIR/dev.zsh"
    add-zsh-hook -d preexec lazy_load_dev
  fi
}
add-zsh-hook preexec lazy_load_dev

# Lazy loading para PHP/Laravel
function lazy_load_php() {
  if [[ "$1" =~ ^(php|composer|pa|sail|pint) ]]; then
    load_module "$ZSH_TOOLS_DIR/php.zsh"
    add-zsh-hook -d preexec lazy_load_php
  fi
}
add-zsh-hook preexec lazy_load_php

# Lazy loading para Node.js
function lazy_load_node() {
  if [[ "$1" =~ ^(node|npm|pnpm|bun|pn|nr|nx|fnm) ]]; then
    load_module "$ZSH_TOOLS_DIR/node.zsh"
    add-zsh-hook -d preexec lazy_load_node
  fi
}
add-zsh-hook preexec lazy_load_node

# Lazy loading para Go
function lazy_load_golang() {
  if [[ "$1" =~ ^go ]]; then
    load_module "$ZSH_TOOLS_DIR/golang.zsh"
    add-zsh-hook -d preexec lazy_load_golang
  fi
}
add-zsh-hook preexec lazy_load_golang

# Lazy loading para Docker
function lazy_load_docker() {
  if [[ "$1" =~ ^docker ]]; then
    load_module "$ZSH_TOOLS_DIR/docker.zsh"
    add-zsh-hook -d preexec lazy_load_docker
  fi
}
add-zsh-hook preexec lazy_load_docker

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