#!/bin/bash

set -e # Detener el script si hay un error

# 🎨 Colores
PINK=$(tput setaf 204)
PURPLE=$(tput setaf 141)
GREEN=$(tput setaf 114)
ORANGE=$(tput setaf 208)
BLUE=$(tput setaf 75)
YELLOW=$(tput setaf 221)
RED=$(tput setaf 196)
NC=$(tput sgr0) # No Color
BOLD="\e[1m"
RESET="\e[0m"

# 🔗 Variables
BREW_URL="hhttps://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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

# Function to prompt user for input with a select menu
select_option() {
  local prompt_message="$1"
  shift
  local options=("$@")
  PS3="${ORANGE}$prompt_message${NC} "
  select opt in "${options[@]}"; do
    if [ -n "$opt" ]; then
      echo "$opt"
      break
    else
      echo -e "${RED}Invalid option. Please try again.${NC}"
    fi
  done
}

#Install basic depenedencies
install_dependencies() {
  if is_arch; then
    run_command "sudo pacman -Syu --noconfirm"
    run_command "sudo pacman -S --needed --noconfirm base-devel curl file git wget"
    run_command "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    run_command ". $HOME/.cargo/env"
  else
    run_command "sudo apt-get update"
    run_command "sudo apt-get install -y build-essential curl file git"
    run_command "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    run_command ". $HOME/.cargo/env"
  fi
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

    run_command "(echo 'eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"' >> ~/.zshrc)"
    run_command "(echo 'eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"' >> ~/.bashrc)"
    run_command "mkdir -p ~/.config/fish"
    run_command "(echo 'eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"' >> ~/.config/fish/config.fish)"
    run_command "eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\""
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

# Function to clone a repository with progress
clone_repository() {
  local repo_url="$1"
  local clone_dir="$2"
  local progress_duration=$3

  echo -e "${YELLOW}Cloning repository...${NC}"
  # Run clone command normally
  git clone "$repo_url" "$clone_dir"
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
# create_symlinks() {
#   print_header "🔗 Creando symlinks"
#
#   FILES=(".zshrc" ".tmux.conf")
#   for file in "${FILES[@]}"; do
#     ln -sf "$CONFIG_DIR/$file" "$HOME/$file"
#     success_msg "Symlink creado: $HOME/$file → $CONFIG_DIR/$file"
#   done
# }

# 🚀 Ejecutar funciones
# Step 1: Clone the Repository
echo -e "${YELLOW}Step 1: Clone the Repository${NC}"
if [ -d "pablo.dots" ]; then
  echo -e "${GREEN}Repository already cloned. Overwriting...${NC}"
  rm -rf "pablo.dots"
fi
clone_repository "https://github.com/Pblo16/pablo.dots.git" "pablo.dots" 20
cd pablo.dots || exit

# Install Homebrew
install_homebrew

# Install packages
install_packages
copy_config_files
# create_symlinks

echo -e "${BOLD}${GREEN}🎉 Instalación completada con éxito.${RESET}"
