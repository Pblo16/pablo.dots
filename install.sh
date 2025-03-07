#!/bin/bash

set -e # Detener el script si hay un error

# 🎨 Colores
GREEN="\e[32m"
BLUE="\e[34m"
YELLOW="\e[33m"
RED="\e[31m"
BOLD="\e[1m"
RESET="\e[0m"

# 🔗 Variables
BREW_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
PACKAGES=("fnm" "pnpm" "zsh" "tmux" "neovim" "zoxide")
CONFIG_DIR="$HOME/.dotfiles"
DEST_DIR="$HOME"

# 🏷️ Función para imprimir encabezados
print_header() {
  echo -e "${BLUE}=================================================${RESET}"
  echo -e "${BOLD}${GREEN}$1${RESET}"
  echo -e "${BLUE}=================================================${RESET}"
}

# ✅ Función para imprimir mensajes de éxito
success_msg() {
  echo -e "${GREEN}✔ $1${RESET}"
}

# ❌ Función para imprimir errores
error_msg() {
  echo -e "${RED}✖ $1${RESET}"
}

# 📦 Función para instalar Homebrew
install_homebrew() {
  print_header "🛠️ Instalando Homebrew"

  if ! command -v brew &>/dev/null; then
    echo "Descargando e instalando Homebrew..."
    /bin/bash -c "$(curl -fsSL $BREW_URL)"
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >>~/.bashrc
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    success_msg "Homebrew instalado correctamente."
  else
    success_msg "Homebrew ya está instalado."
  fi
}

# 📥 Función para instalar paquetes
install_packages() {
  print_header "📦 Instalando paquetes con Homebrew"

  for pkg in "${PACKAGES[@]}"; do
    echo -ne "${YELLOW}Instalando $pkg...${RESET}"
    if brew list "$pkg" &>/dev/null; then
      echo -e " ${GREEN}[Ya instalado]${RESET}"
    else
      brew install "$pkg" &>/dev/null && success_msg "$pkg instalado."
    fi
  done
}

# 📂 Función para copiar archivos de configuración
copy_config_files() {
  print_header "📂 Copiando archivos de configuración"

  FILES=(".zshrc" ".tmux.conf")
  for file in "${FILES[@]}"; do
    if [ -f "$CONFIG_DIR/$file" ]; then
      cp "$CONFIG_DIR/$file" "$DEST_DIR"
      success_msg "$file copiado a $DEST_DIR."
    else
      error_msg "Archivo $file no encontrado en $CONFIG_DIR."
    fi
  done
}

# 🔗 Función para crear symlinks
create_symlinks() {
  print_header "🔗 Creando symlinks"

  FILES=(".zshrc" ".tmux.conf")
  for file in "${FILES[@]}"; do
    ln -sf "$CONFIG_DIR/$file" "$HOME/$file"
    success_msg "Symlink creado: $HOME/$file → $CONFIG_DIR/$file"
  done
}

# 🚀 Ejecutar funciones
install_homebrew
install_packages
copy_config_files
create_symlinks

echo -e "${BOLD}${GREEN}🎉 Instalación completada con éxito.${RESET}"
