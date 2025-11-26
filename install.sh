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
REPO_BRANCH="main"
REPO_DIR="pablo.dots"
ZOXIDE_URL="https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh"
ATUIN_URL="https://setup.atuin.sh"

# Paquetes
BREW_PACKAGES=(
  "fnm"
  "pnpm"
  "neovim"
  "gh"
  "ripgrep"
  "jandedobbeleer/oh-my-posh/oh-my-posh"
  "lazygit"
  "fzf"
  "go"
)

APT_PACKAGES=(
  "build-essential"
  "curl"
  "file"
  "git"
  "zsh"
  "lsd"
  "unzip"
  "p7zip"
  "docker.io"
)

# Directorios
CONFIG_DIR="$HOME/.config"
NVIM_CONFIG_DIR="$CONFIG_DIR/nvim"

# =====================================================
# 🛠️ FUNCIONES AUXILIARES
# =====================================================

# Función para imprimir encabezados
print_header() {
  local text="$1"
  local len=${#text}
  local width=$((len + 4))
  local top_bottom=$(printf '═%.0s' $(seq 1 $width))
  echo -e "${BLUE}╔${top_bottom}╗${RESET}"
  echo -e "${BLUE}║  ${BOLD}${GREEN}${text}${RESET}  ${BLUE}║${RESET}"
  echo -e "${BLUE}╚${top_bottom}╝${RESET}"
  echo
}

# Función para mostrar un spinner
spinner() {
  local pid=$1
  local delay=0.1
  local spinstr='|/-\'
  while ps -p $pid > /dev/null; do
    local temp=${spinstr#?}
    printf " [%c]  " "$spinstr"
    local spinstr=$temp${spinstr%"$temp"}
    sleep $delay
    printf "\b\b\b\b\b\b"
  done
  printf "    \b\b\b\b\b"
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
    eval "$command" &>/dev/null &
    local cmd_pid=$!
    spinner $cmd_pid
    wait $cmd_pid
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
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

  # Guardamos la ubicación del repositorio clonado para su uso posterior
  DOTFILES_PATH=$(pwd)
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
      if brew install "$pkg"; then
        success_msg "$pkg instalado."
      else
        error_msg "Error al instalar $pkg"
        # Continuar con la instalación en lugar de salir
        info_msg "Continuando con la instalación de otros paquetes..."
      fi
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

  # Instalar atuin - Mejorado para añadir al PATH
  if ! is_installed atuin; then
    info_msg "Instalando atuin..."
    run_command "curl --proto '=https' --tlsv1.2 -LsSf $ATUIN_URL | sh" false

    # Asegurar que atuin esté en el PATH y sea encontrable
    if [[ -d "$HOME/.atuin/bin" ]]; then
      info_msg "Configurando variables de entorno para atuin..."
      # Añadir esto al archivo .zshenv para asegurar que esté disponible temprano
      if ! grep -q "atuin/bin/env" "$HOME/.zshenv"; then
        echo '. "$HOME/.atuin/bin/env"' >>"$HOME/.zshenv"
      fi
    fi
  else
    info_msg "atuin ya está instalado"
  fi

  # Configurar Docker si está instalado
  if is_installed docker; then
    info_msg "Configurando Docker..."
    run_command "sudo usermod -aG docker $USER" false
    run_command "sudo systemctl enable docker" false
    run_command "sudo systemctl start docker" false
  fi

  success_msg "Herramientas adicionales instaladas correctamente"
}

# Configurar Zsh
configure_zsh() {
  print_header "🐚 Configurando Zsh"
  # Copiar archivo de configuración de Zsh
  run_command "cp -rf .zshrc $HOME/" false

  success_msg "Zsh configurado correctamente"
}

# Instalar Zinit
install_zinit() {
  print_header "📦 Instalando Zinit"

  if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    run_command "command mkdir -p \"$HOME/.local/share/zinit\" && command chmod g-rwX \"$HOME/.local/share/zinit\"" false
    run_command "command git clone https://github.com/zdharma-continuum/zinit \"$HOME/.local/share/zinit/zinit.git\"" false
    success_msg "Zinit instalado correctamente"
  else
    info_msg "Zinit ya está instalado"
  fi
}

# Configurar Neovim
configure_neovim() {
  print_header "📝 Configurando Neovim"

  # Verificar la ubicación correcta del directorio nvim
  local nvim_source_dir

  # Comprobar si existe en el directorio de trabajo actual (donde se ejecuta el script)
  if [ -d "./nvim" ] && [ "$(ls -A ./nvim 2>/dev/null)" ]; then
    nvim_source_dir="./nvim"
  # Comprobar si existe en el directorio del repositorio clonado
  elif [ -d "$DOTFILES_PATH/nvim" ] && [ "$(ls -A $DOTFILES_PATH/nvim 2>/dev/null)" ]; then
    nvim_source_dir="$DOTFILES_PATH/nvim"
  # Comprobar si existe en el directorio home
  elif [ -d "$HOME/pablo.dots/nvim" ] && [ "$(ls -A $HOME/pablo.dots/nvim 2>/dev/null)" ]; then
    nvim_source_dir="$HOME/pablo.dots/nvim"
  fi

  if [ -n "$nvim_source_dir" ]; then
    # Copiar configuración de Neovim
    info_msg "Usando configuración de Neovim desde: $nvim_source_dir"
    run_command "mkdir -p $NVIM_CONFIG_DIR" false
    run_command "cp -rf $nvim_source_dir/* $NVIM_CONFIG_DIR/" false
    success_msg "Neovim configurado correctamente"
  else
    info_msg "No se encontró la configuración de Neovim en el repositorio"
    info_msg "Creando una configuración básica de Neovim..."

    # Crear una configuración básica de init.lua
    mkdir -p "$NVIM_CONFIG_DIR"
    cat >"$NVIM_CONFIG_DIR/init.lua" <<'EOL'
-- Basic Neovim configuration
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.autoindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smarttab = true
vim.opt.softtabstop = 2
vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Basic keybindings
vim.g.mapleader = ' '
vim.keymap.set('n', '<leader>w', '<cmd>write<cr>', { desc = 'Save' })
vim.keymap.set('n', '<leader>q', '<cmd>quit<cr>', { desc = 'Quit' })

-- Detect file types
vim.cmd('filetype plugin indent on')
vim.cmd('syntax enable')
EOL

    success_msg "Configuración básica de Neovim creada correctamente"
    info_msg "Puedes personalizar tu configuración en: $NVIM_CONFIG_DIR"
  fi
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

# Configurar estructura de archivos ZSH
setup_zsh_structure() {
  print_header "📂 Configurando estructura de archivos ZSH"

  # Crear directorios para modularizar .zsh
  mkdir -p "$HOME/.zsh/"{lib,tools,plugins,completions}

  # Copiar archivos de configuración modular
  if [ -d "$DOTFILES_PATH/.zsh" ]; then
    run_command "cp -r $DOTFILES_PATH/.zsh/* $HOME/.zsh/" false
  fi

  success_msg "Estructura de archivos ZSH configurada correctamente"
}

# Configurar directorio de configuración centralizado
setup_config_dir() {
  print_header "🔧 Configurando directorio centralizado de configuración"

  # Crear directorio principal de configuración
  DOTS_CONFIG_DIR="$HOME/dots.config"
  mkdir -p "$DOTS_CONFIG_DIR"

  # Crear subdirectorios para diferentes tipos de configuración
  mkdir -p "$DOTS_CONFIG_DIR/"{shell,prompt,terminal,development,backups}

  # Copiar archivo de configuración de Oh-My-Posh
  if [ -f "$DOTFILES_PATH/php.omp.json" ]; then
    run_command "cp $DOTFILES_PATH/php.omp.json $DOTS_CONFIG_DIR/prompt/" false
  fi

  # Crear archivo de configuración de ZSH (para personalización fácil)
  cat >"$DOTS_CONFIG_DIR/shell/zsh_custom.zsh" <<'EOL'
# Archivo para personalizaciones de ZSH
# Este archivo se carga al final de .zshrc y no será sobrescrito en las actualizaciones

# Agrega aquí tus personalizaciones, alias y funciones:

# Ejemplo: Alias personalizados
# alias myalias="comando"

# Ejemplo: Variables de entorno personalizadas
# export MY_VAR="valor"

# Ejemplo: Funciones personalizadas
# my_function() {
#   echo "Mi función personalizada"
# }
EOL

  # Crear archivo de configuración para desarrollo (herramientas)
  cat >"$DOTS_CONFIG_DIR/development/tools.sh" <<'EOL'
# Configuración de herramientas de desarrollo
# Este archivo puede ser modificado para personalizar herramientas específicas

# Ejemplos:
# export JAVA_HOME="/path/to/java"
# export MAVEN_HOME="/path/to/maven"
# export ANDROID_HOME="/path/to/android/sdk"

# Configuración de editores
# export EDITOR="nvim"
# export VISUAL="code"
EOL

  # Crear archivo de configuración para proyectos (rutas y atajos)
  cat >"$DOTS_CONFIG_DIR/development/projects.sh" <<'EOL'
# Configuración relacionada con proyectos
# Define aquí paths a proyectos frecuentes o atajos para navegar entre ellos

# Ejemplos:
# export PROJECTS_DIR="$HOME/Projects"
# alias pj-web="cd $PROJECTS_DIR/my-web-project"
# alias pj-api="cd $PROJECTS_DIR/my-api-project"
EOL

  # Crear README para explicar la estructura
  cat >"$DOTS_CONFIG_DIR/README.md" <<'EOL'
# Directorio de Configuración Centralizada

Este directorio contiene los archivos de configuración que puedes personalizar
para adaptar tu entorno de desarrollo a tus necesidades.

## Estructura:

- **shell/**: Configuraciones relacionadas con la shell (ZSH)
  - `zsh_custom.zsh`: Personalizaciones para ZSH

- **prompt/**: Temas y configuración de prompt
  - `php.omp.json`: Configuración de Oh-My-Posh

- **terminal/**: Configuraciones para el terminal

- **development/**: Configuraciones para herramientas de desarrollo
  - `tools.sh`: Configuración de herramientas y lenguajes
  - `projects.sh`: Atajos para proyectos específicos

- **backups/**: Directorio para guardar copias de seguridad de configuraciones previas

## Uso:

Modifica cualquiera de estos archivos según tus preferencias. Estos archivos
se cargarán automáticamente y no serán sobrescritos en futuras actualizaciones.
EOL

  # Actualizar los permisos de los archivos
  run_command "chmod -R u+w $DOTS_CONFIG_DIR" false

  success_msg "Directorio de configuración centralizado creado correctamente"
  info_msg "Puedes personalizar tus configuraciones en: $DOTS_CONFIG_DIR"
}

# Actualizar referencias en archivos de configuración
update_config_references() {
  print_header "🔄 Actualizando referencias en archivos de configuración"

  # Actualizar referencia en .zshrc para cargar configuraciones personalizadas
  if [ -f "$HOME/.zshrc" ]; then
    # Verificar si ya existe la línea de carga personalizada
    if ! grep -q "DOTS_CONFIG_DIR" "$HOME/.zshrc"; then
      echo -e "\n# Cargar configuraciones personalizadas\nDOTS_CONFIG_DIR=\"\$HOME/dots.config\"\n[[ -f \"\$DOTS_CONFIG_DIR/shell/zsh_custom.zsh\" ]] && source \"\$DOTS_CONFIG_DIR/shell/zsh_custom.zsh\"" >>"$HOME/.zshrc"
      success_msg "Configuración personalizada añadida a .zshrc"
    fi
  fi

  # Actualizar referencia en archivo de prompt.zsh
  PROMPT_FILE="$HOME/.zsh/tools/prompt.zsh"
  if [ -f "$PROMPT_FILE" ]; then
    sed -i 's|~/dots.config/php.opm.json|~/dots.config/prompt/php.omp.json|g' "$PROMPT_FILE"
    success_msg "Referencias actualizadas en archivo de prompt"
  fi

  # Actualizar referencia en archivos de desarrollo
  DEV_FILE="$HOME/.zsh/tools/dev.zsh"
  if [ -f "$DEV_FILE" ]; then
    echo -e "\n# Cargar configuraciones de desarrollo personalizadas\n[[ -f \"\$HOME/dots.config/development/tools.sh\" ]] && source \"\$HOME/dots.config/development/tools.sh\"\n[[ -f \"\$HOME/dots.config/development/projects.sh\" ]] && source \"\$HOME/dots.config/development/projects.sh\"" >>"$DEV_FILE"
    success_msg "Referencias de desarrollo actualizadas"
  fi

  success_msg "Referencias en archivos de configuración actualizadas correctamente"
}

# Limpiar después de la instalación
cleanup() {
  print_header "🧹 Limpiando"

  # Asegurar permisos correctos para Homebrew
  if command -v brew &>/dev/null; then
    run_command "sudo chown -R $(whoami) $(brew --prefix)/*" false
  fi

  # Volver al directorio original si es necesario
  if [ -n "$ORIGINAL_DIR" ] && [ -d "$ORIGINAL_DIR" ]; then
    cd "$ORIGINAL_DIR"
  fi

  # Nota: No eliminar el repositorio ni el script de instalación
  # Esto evita problemas si el script se está ejecutando desde el repositorio
  success_msg "Limpieza completada"
}

# =====================================================
# 🚀 FUNCIÓN PRINCIPAL
# =====================================================

main() {
  echo -e "${PURPLE}${BOLD}🚀 Bienvenido al Instalador Moderno de Dotfiles${RESET}"
  echo -e "${BLUE}Configurando tu entorno de desarrollo con estilo...${RESET}"
  echo

  print_header "🚀 Iniciando instalación de dotfiles"

  # Guardar directorio original
  ORIGINAL_DIR=$(pwd)

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
  configure_zsh
  install_zinit
  setup_zsh_structure
  setup_config_dir         # Nueva función para crear estructura de configuración centralizada
  update_config_references # Nueva función para actualizar referencias de archivos
  configure_neovim
  set_default_shell
  cleanup

  print_header "🎉 ¡Instalación completada con éxito!"
  echo -e "${BOLD}${GREEN}Para aplicar todos los cambios, cierre y vuelva a abrir su terminal${RESET}"
  echo -e "${BOLD}${GREEN}O ejecute: exec zsh${RESET}"
  echo -e "${BOLD}${YELLOW}Personaliza tus configuraciones en: ${RESET}${BOLD}~/dots.config/${RESET}"

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
