#!/bin/bash

# Detener el script si hay un error
set -e

# =====================================================
# 🎨 CONFIGURACIÓN Y VARIABLES
# =====================================================

# Colores para formatear la salida
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

# URLs y configuración
BREW_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
REPO_URL="https://github.com/Pblo16/pablo.dots.git"
REPO_BRANCH="testing"
REPO_DIR="pablo.dots"
ZOXIDE_URL="https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh"
ATUIN_URL="https://setup.atuin.sh"

# Paquetes
BREW_PACKAGES=(
  "fnm"
  "pnpm"
  "neovim"
  "fzf"
  "ripgrep"
  "jandedobbeleer/oh-my-posh/oh-my-posh"
  "lazygit"
  "zsh-autosuggestions"
  "zsh-syntax-highlighting"
  "zsh-autocomplete"
)

APT_PACKAGES=(
  "build-essential"
  "curl"
  "file"
  "git"
  "zsh"
  "lsd"
)

# Directorios
CONFIG_DIR="$HOME/.config"
NVIM_CONFIG_DIR="$CONFIG_DIR/nvim"
TMUX_CONFIG_DIR="$HOME/.tmux"
TMUX_SESSION_NAME="plugin-installation"

# =====================================================
# 🛠️ FUNCIONES AUXILIARES
# =====================================================

# Función para imprimir encabezados
print_header() {
  echo -e "${BLUE}=================================================${RESET}"
  echo -e "${BOLD}${GREEN}$1${RESET}"
  echo -e "${BLUE}=================================================${RESET}"
}

# Función para imprimir mensajes de éxito
success_msg() {
  echo -e "${GREEN}✅ $1${RESET}"
}

# Función para imprimir mensajes informativos
info_msg() {
  echo -e "${YELLOW}ℹ️ $1${RESET}"
}

# Función para imprimir errores
error_msg() {
  echo -e "${RED}❌ $1${RESET}"
}

# Función para ejecutar comandos
run_command() {
  local command="$1"
  local hide_output="${2:-false}"
  local error_message="${3:-Error al ejecutar: $command}"

  info_msg "Ejecutando: $command"

  if [ "$hide_output" = "true" ]; then
    if eval "$command" &>/dev/null; then
      success_msg "Comando ejecutado con éxito"
    else
      error_msg "$error_message"
      exit 1
    fi
  else
    if eval "$command"; then
      success_msg "Comando ejecutado con éxito"
    else
      error_msg "$error_message"
      exit 1
    fi
  fi
}

# Función para verificar si un paquete está instalado
is_installed() {
  local pkg="$1"
  command -v "$pkg" &>/dev/null
}

# Función para seleccionar opciones
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
      error_msg "Opción inválida. Inténtalo de nuevo."
    fi
  done
}

# =====================================================
# 📋 FUNCIONES DE INSTALACIÓN
# =====================================================

# Verificar y crear directorios necesarios
setup_directories() {
  print_header "📁 Configurando directorios"

  mkdir -p "$HOME/.local/share/atuin"
  mkdir -p "$NVIM_CONFIG_DIR"
  mkdir -p "$TMUX_CONFIG_DIR"

  success_msg "Directorios creados correctamente"
}

# Instalar dependencias básicas
install_basic_dependencies() {
  print_header "🛠️ Instalando dependencias básicas"

  run_command "sudo apt-get update" true

  for pkg in "${APT_PACKAGES[@]}"; do
    if dpkg -l | grep -q "$pkg"; then
      info_msg "$pkg ya está instalado"
    else
      info_msg "Instalando $pkg..."
      run_command "sudo apt-get install -y $pkg" false "Error al instalar $pkg"
    fi
  done

  success_msg "Dependencias básicas instaladas correctamente"
}

# Instalar Rust
install_rust() {
  print_header "🦀 Instalando Rust"

  if is_installed rustc; then
    info_msg "Rust ya está instalado"
  else
    run_command "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y" false
    run_command "source $HOME/.cargo/env"
  fi

  success_msg "Rust instalado correctamente"
}

# Clonar repositorio de dotfiles
clone_dotfiles_repo() {
  print_header "📦 Clonando repositorio de dotfiles"

  # Guardar directorio actual
  local current_dir=$(pwd)

  # Verificar si el repositorio ya existe
  if [ -d "$REPO_DIR" ]; then
    info_msg "Repositorio ya clonado. Actualizando..."
    run_command "cd $REPO_DIR && git pull" false
  else
    run_command "git clone -b $REPO_BRANCH --single-branch $REPO_URL $REPO_DIR" false
  fi

  # Cambiar al directorio del repositorio
  cd "$REPO_DIR" || exit 1

  success_msg "Repositorio clonado/actualizado correctamente"
}

# Instalar Homebrew
install_homebrew() {
  print_header "🍺 Instalando Homebrew"

  if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL $BREW_URL)"
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >>~/.bashrc
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    success_msg "Homebrew instalado correctamente."

    run_command "(echo 'eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"' >> ~/.zshrc)"
    run_command "(echo 'eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"' >> ~/.bashrc)"
    run_command "eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\""
  else
    success_msg "Homebrew ya está instalado."
  fi

}

# Instalar paquetes de Homebrew
install_brew_packages() {
  print_header "📦 Instalando paquetes con Homebrew"

  for pkg in "${BREW_PACKAGES[@]}"; do
    echo -ne "${YELLOW}Instalando $pkg...${RESET}"
    if brew list "$pkg" &>/dev/null; then
      echo -e " ${GREEN}[Ya instalado]${RESET}"
    else
      brew install "$pkg" &>/dev/null && success_msg "$pkg instalado."
    fi
  done

  success_msg "Paquetes de Homebrew instalados correctamente"
}

# Instalar y configurar herramientas adicionales
install_additional_tools() {
  print_header "🔧 Instalando herramientas adicionales"

  # Instalar zoxide
  if ! is_installed zoxide; then
    info_msg "Instalando zoxide..."
    run_command "curl -sSfL $ZOXIDE_URL | sh" false
  else
    info_msg "zoxide ya está instalado"
  fi

  # Instalar atuin
  if ! is_installed atuin; then
    info_msg "Instalando atuin..."
    run_command "curl --proto '=https' --tlsv1.2 -LsSf $ATUIN_URL | sh" false
  else
    info_msg "atuin ya está instalado"
  fi

  success_msg "Herramientas adicionales instaladas correctamente"
}

# Configurar Node.js con fnm e instalar paquetes globales
setup_nodejs() {
  print_header "📦 Configurando Node.js y paquetes globales"

  # Verificar si fnm está instalado
  if is_installed fnm; then
    # Instalar última versión LTS de Node.js
    info_msg "Instalando última versión LTS de Node.js..."
    run_command "fnm install --lts" false

    # Establecer como versión por defecto
    run_command "fnm default lts-latest" true

    # Instalar paquetes globales con pnpm
    if is_installed pnpm; then
      info_msg "Instalando paquetes globales con pnpm..."
      run_command "pnpm add -g @astrojs/language-server" false "Error al instalar @astrojs/language-server"
      # Aquí puedes añadir más paquetes globales si son necesarios en el futuro
    else
      error_msg "pnpm no está instalado. No se pueden instalar los paquetes globales."
    fi
  else
    error_msg "fnm no está instalado. No se puede configurar Node.js."
  fi

  success_msg "Node.js y paquetes globales configurados correctamente"
}

# Configurar Zsh
configure_zsh() {
  print_header "🐚 Configurando Zsh"
  # Copiar archivo de configuración de Zsh
  run_command "cp -rf .zshrc $HOME/" false
  run_command "git clone https://github.com/Aloxaf/fzf-tab ~/dots.config/fzf-tab.plugin.zsh"
  success_msg "Zsh configurado correctamente"
}

# Configurar Tmux
configure_tmux() {
  print_header "📟 Configurando Tmux"

  # Instalar Tmux Plugin Manager (TPM) si no existe
  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    run_command "git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm" false
  else
    info_msg "Tmux Plugin Manager ya está instalado"
  fi

  # Copiar configuración de Tmux
  run_command "cp -r .tmux/* $TMUX_CONFIG_DIR/" false
  run_command "cp .tmux.conf $HOME/" false

  # Instalar plugins de Tmux
  info_msg "Instalando plugins de Tmux..."

  # Matar sesión anterior si existe
  if tmux has-session -t $TMUX_SESSION_NAME 2>/dev/null; then
    run_command "tmux kill-session -t $TMUX_SESSION_NAME" true
  fi

  # Crear una nueva sesión de tmux e instalar plugins
  run_command "tmux new-session -d -s $TMUX_SESSION_NAME 'source ~/.tmux.conf; tmux run-shell ~/.tmux/plugins/tpm/bin/install_plugins'" false

  # Esperar a que termine la instalación
  info_msg "Esperando a que finalice la instalación de plugins de Tmux..."
  sleep 5

  # Matar la sesión
  if tmux has-session -t $TMUX_SESSION_NAME 2>/dev/null; then
    run_command "tmux kill-session -t $TMUX_SESSION_NAME" true
  fi

  success_msg "Tmux configurado correctamente"
}

# Configurar Neovim
configure_neovim() {
  print_header "📝 Configurando Neovim"

  # Copiar configuración de Neovim
  run_command "cp -rf nvim/* $NVIM_CONFIG_DIR/" false

  success_msg "Neovim configurado correctamente"
}

# Establecer shell por defecto
set_default_shell() {
  print_header "🐚 Estableciendo shell por defecto"

  local shell_name="zsh"
  local shell_path
  shell_path=$(which "$shell_name")

  if [ -n "$shell_path" ]; then
    # Añadir shell a /etc/shells si no existe
    run_command "grep -Fxq \"$shell_path\" /etc/shells || sudo sh -c \"echo $shell_path >> /etc/shells\"" true

    # Cambiar shell por defecto
    run_command "sudo chsh -s $shell_path $USER" false

    if [ "$SHELL" != "$shell_path" ]; then
      info_msg "Es posible que necesites reiniciar para que los cambios surtan efecto"
      info_msg "Comando para cambiar shell manualmente: sudo chsh -s $shell_path \$USER"
    else
      success_msg "Shell cambiado a $shell_path correctamente"
    fi
  else
    error_msg "Shell $shell_name no encontrado"
  fi
}

# Limpiar después de la instalación
cleanup() {
  print_header "🧹 Limpiando"

  # Asegurar permisos correctos para Homebrew
  run_command "sudo chown -R $(whoami) $(brew --prefix)/*" false

  # Volver al directorio original y eliminar el repositorio clonado
  cd ..
  run_command "rm -rf $REPO_DIR" false

  success_msg "Limpieza completada"
}

# =====================================================
# 🚀 FUNCIÓN PRINCIPAL
# =====================================================

main() {
  print_header "🚀 Iniciando instalación de dotfiles"

  # Verificar si se ejecuta como root
  if [ "$(id -u)" -eq 0 ]; then
    error_msg "Este script no debe ser ejecutado como root"
    exit 1
  fi

  # Ejecutar los pasos de instalación
  setup_directories
  install_basic_dependencies
  install_rust
  clone_dotfiles_repo
  install_homebrew
  install_brew_packages
  install_additional_tools
  # setup_nodejs # Añadida la nueva función aquí
  configure_zsh
  configure_tmux
  configure_neovim
  set_default_shell
  cleanup

  print_header "🎉 ¡Instalación completada con éxito!"
  echo -e "${BOLD}${GREEN}Para aplicar todos los cambios, cierre y vuelva a abrir su terminal${RESET}"
  echo -e "${BOLD}${GREEN}O ejecute: exec zsh${RESET}"

  # Asegurar que estemos usando zsh al final
  if [ -x "$(command -v zsh)" ]; then
    echo -e "\n${YELLOW}Iniciando nueva sesión de zsh...${RESET}"
    sleep 1
    # Usar esta técnica para asegurar que exec zsh se ejecute como el último comando
    exec zsh -l
  else
    echo -e "\n${RED}zsh no está disponible. Por favor instálelo e inicie una nueva sesión.${RESET}"
  fi
}

# Ejecutar función principal
main
