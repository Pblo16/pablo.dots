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
BREW_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
PACKAGES=("fnm" "pnpm" "neovim" "jandedobbeleer/oh-my-posh/oh-my-posh" "lazygit")
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

# Function to run commands with optional suppression of output
run_command() {
  local command=$1
  eval $command
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
  run_command "sudo apt-get update"
  run_command "sudo apt-get install -y build-essential curl file git"
  run_command "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
  run_command ". $HOME/.cargo/env"
}

print_header "🛠️ Installing dependencies"
install_dependencies

# Function to clone a repository with progress
clone_repository() {
  local repo_url="$1"
  local clone_dir="$2"
  local progress_duration=$3

  echo -e "${YELLOW}Cloning repository...${NC}"
  # Run clone command normally
  git clone "$repo_url" "$clone_dir"
}

# Step 1: Clone the repository
echo -e "${YELLOW}Step 1: Clone the Repository${NC}"
if [ -d "pablo.dots" ]; then
  echo -e "${GREEN}Repository already cloned. Overwriting...${NC}"
  rm -rf "pablo.dots"
fi
clone_repository "https://github.com/Pblo16/pablo.dots.git" "pablo.dots" 20

cd pablo.dots || exit

# Step 2: Install Homebrew
echo -e "${YELLOW}Step 2: Install Homebrew"

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

# Step 3: Install Dependencies
echo -e "${YELLOW}Step 3: Dependencies"
print_header "📦 Instalando paquetes con Homebrew"

for pkg in "${PACKAGES[@]}"; do
  echo -ne "${YELLOW}Instalando $pkg...${RESET}"
  if brew list "$pkg" &>/dev/null; then
    echo -e " ${GREEN}[Ya instalado]${RESET}"
  else
    brew install "$pkg" &>/dev/null && success_msg "$pkg instalado."
  fi
done

#Step 4: Install Shell
echo -e "${YELLOW}Step 4: Install Shell"

echo -e "${YELLOW}Configuring Zsh...${NC}"
run_command "sudo apt install zsh -y"
#install zoxide
run_command "curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh"
#install LSD
run_command "sudo apt install lsd -y"
#install atuin
run_command "curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh"

mkdir -p ~/.cache/carapace
mkdir -p ~/.local/share/atuin

run_command "cp -rf .zshrc ~/"

echo -e "${YELLOW}Configuring Tmux...${NC}"
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  run_command "git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm"
else
  echo -e "${GREEN}Tmux Plugin Manager is already installed.${NC}"
fi

run_command "mkdir -p ~/.tmux"
run_command "pwd"
run_command "cp -r .tmux/* ~/.tmux/"
run_command "cp .tmux.conf ~/"
SESSION_NAME="plugin-installation"

# Check if session already exists and kill it if necessary
if tmux has-session -t $SESSION_NAME 2>/dev/null; then
  echo -e "${YELLOW}Session $SESSION_NAME already exists. Killing it...${NC}"
  tmux kill-session -t $SESSION_NAME
fi

# Create a new session in detached mode with the specified name
tmux new-session -d -s $SESSION_NAME 'source ~/.tmux.conf; tmux run-shell ~/.tmux/plugins/tpm/bin/install_plugins'

# Wait for a few seconds to ensure the installation completes
while tmux has-session -t $SESSION_NAME 2>/dev/null; do
  sleep 1
done

# Ensure the tmux session is killed
if tmux has-session -t $SESSION_NAME 2>/dev/null; then
  tmux kill-session -t $SESSION_NAME
fi

#Step: install lazyvim
echo -e "${YELLOW}Configuring Neovim...${NC}"
run_command "mkdir -p ~/.config/nvim"
run_command "cp -rf .config/nvim/* ~/.config/nvim/"
run_command "nvim +PackerSync"

# Clean up: Remove the cloned repository
sudo chown -R $(whoami) $(brew --prefix)/*
echo -e "${YELLOW}Cleaning up...${NC}"
cd ..
run_command "rm -rf pablo.dots"

set_as_default_shell "zsh"

echo -e "${BOLD}${GREEN}🎉 Instalación completada con éxito.${RESET}"
exec zsh
