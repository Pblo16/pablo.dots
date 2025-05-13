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
  "fnm" "pnpm" "neovim" "fzf" "gh" "ripgrep" 
  "jandedobbeleer/oh-my-posh/oh-my-posh" "lazygit"
  "zsh-autosuggestions" "zsh-syntax-highlighting"
)

APT_PACKAGES=(
  "build-essential" "curl" "file" "git" "zsh" "lsd" "unzip"
)

# Directorios
CONFIG_DIR="$HOME/.config"
NVIM_CONFIG_DIR="$CONFIG_DIR/nvim"
TMUX_CONFIG_DIR="$HOME/.tmux"
TMUX_SESSION_NAME="dotfiles-setup"
DOTS_CONFIG_DIR="$HOME/dots.config"

# =====================================================
# 🛠️ FUNCIONES AUXILIARES
# =====================================================

# Función para imprimir mensajes formateados
print_header() { echo -e "${BLUE}=================================================\n${BOLD}${GREEN}$1${RESET}\n${BLUE}=================================================${RESET}"; }
success_msg() { echo -e "${GREEN}✅ $1${RESET}"; }
info_msg() { echo -e "${YELLOW}ℹ️ $1${RESET}"; }
error_msg() { echo -e "${RED}❌ $1${RESET}"; }

# Función para ejecutar comandos con manejo de errores
run_command() {
  local command="$1"
  local hide_output="${2:-false}"
  local error_message="${3:-Error al ejecutar: $command}"

  info_msg "Ejecutando: $command"

  if [ "$hide_output" = "true" ]; then
    if eval "$command" &>/dev/null; then success_msg "Comando ejecutado con éxito"; else error_msg "$error_message"; exit 1; fi
  else
    if eval "$command"; then success_msg "Comando ejecutado con éxito"; else error_msg "$error_message"; exit 1; fi
  fi
}

# Verificar si un paquete/comando está instalado
is_installed() { command -v "$1" &>/dev/null; }

# Función para crear directorios si no existen
ensure_dir() { [ ! -d "$1" ] && mkdir -p "$1"; }

# Función para instalar paquetes con apt
install_apt_package() {
  local pkg="$1"
  if dpkg -l | grep -q "$pkg"; then
    info_msg "$pkg ya está instalado"
  else
    info_msg "Instalando $pkg..."
    run_command "sudo apt-get install -y $pkg" false "Error al instalar $pkg"
  fi
}

# Función para instalar paquetes con brew
install_brew_package() {
  local pkg="$1"
  echo -ne "${YELLOW}Instalando $pkg...${RESET}"
  if brew list "$pkg" &>/dev/null; then
    echo -e " ${GREEN}[Ya instalado]${RESET}"
  else
    if brew install "$pkg"; then
      success_msg "$pkg instalado."
    else
      error_msg "Error al instalar $pkg"
      info_msg "Continuando con la instalación de otros paquetes..."
    fi
  fi
}

# Función para clonar o actualizar un repositorio git
clone_or_update_repo() {
  local url="$1"
  local dir="$2"
  local branch="${3:-main}"
  
  if [ -d "$dir/.git" ]; then
    info_msg "Repositorio en $dir ya existe. Actualizando..."
    (cd "$dir" && git pull)
  else
    info_msg "Clonando repositorio en $dir..."
    git clone --depth=1 ${branch:+--branch $branch} "$url" "$dir"
  fi
}

# Función para copiar archivos de configuración
copy_config() {
  local src="$1"
  local dest="$2"
  
  if [ -e "$src" ]; then
    ensure_dir "$(dirname "$dest")"
    run_command "cp -rf $src $dest" false "Error al copiar $src a $dest"
    success_msg "Configuración copiada: $src → $dest"
  else
    info_msg "Archivo de origen no encontrado: $src"
  fi
}

# =====================================================
# 📋 FUNCIONES DE INSTALACIÓN PRINCIPALES
# =====================================================

# Verificar y crear directorios necesarios
setup_directories() {
  print_header "📁 Configurando directorios"
  
  local dirs=(
    "$HOME/.local/share/atuin"
    "$NVIM_CONFIG_DIR"
    "$DOTS_CONFIG_DIR"
    "$DOTS_CONFIG_DIR/"{shell,prompt,terminal,development,backups}
    "$HOME/.zsh/"{lib,tools,plugins,completions}
  )
  
  for dir in "${dirs[@]}"; do
    ensure_dir "$dir"
  done
  
  success_msg "Directorios creados correctamente"
}

# Instalar dependencias básicas
install_basic_dependencies() {
  print_header "🛠️ Instalando dependencias básicas"
  run_command "sudo apt-get update" true
  
  for pkg in "${APT_PACKAGES[@]}"; do
    install_apt_package "$pkg"
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

  clone_or_update_repo "$REPO_URL" "$REPO_DIR" "$REPO_BRANCH"
  
  # Cambiar al directorio del repositorio
  cd "$REPO_DIR" || exit 1
  success_msg "Repositorio clonado/actualizado correctamente"
  
  # Guardamos la ubicación del repositorio clonado para su uso posterior
  DOTFILES_PATH=$(pwd)
}

# Instalar Homebrew y paquetes
install_homebrew_and_packages() {
  print_header "🍺 Instalando Homebrew y paquetes"

  # Instalar Homebrew si es necesario
  if ! is_installed brew; then
    run_command "/bin/bash -c \"$(curl -fsSL $BREW_URL)\"" false
    run_command "echo 'eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"' >> ~/.zshrc" true
    run_command "echo 'eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"' >> ~/.bashrc" true
    run_command "eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"" true
    success_msg "Homebrew instalado correctamente"
  else
    success_msg "Homebrew ya está instalado"
  fi
  
  # Instalar paquetes de Homebrew
  for pkg in "${BREW_PACKAGES[@]}"; do
    install_brew_package "$pkg"
  done
  
  success_msg "Paquetes de Homebrew instalados correctamente"
}

# Instalar herramientas adicionales (zoxide, atuin)
install_additional_tools() {
  print_header "🔧 Instalando herramientas adicionales"
  
  # Instalar zoxide
  if ! is_installed zoxide; then
    info_msg "Instalando zoxide..."
    run_command "curl -sSfL $ZOXIDE_URL | sh" false
  else
    info_msg "zoxide ya está instalado"
  fi

  # Instalar atuin con configuración de PATH
  if ! is_installed atuin; then
    info_msg "Instalando atuin..."
    run_command "curl --proto '=https' --tlsv1.2 -LsSf $ATUIN_URL | sh" false
    
    # Configurar atuin en .zshenv
    if [[ -d "$HOME/.atuin/bin" ]] && ! grep -q "atuin/bin/env" "$HOME/.zshenv"; then
      echo '. "$HOME/.atuin/bin/env"' >> "$HOME/.zshenv"
      echo 'eval "$(atuin init zsh)"' >> "$HOME/.zshenv"
    fi
  else
    info_msg "atuin ya está instalado"
  fi

  success_msg "Herramientas adicionales instaladas correctamente"
}

# Configurar ZSH y sus plugins
configure_zsh_environment() {
  print_header "🐚 Configurando entorno ZSH"
  
  # Copiar configuraciones de ZSH
  copy_config "$DOTFILES_PATH/.zshrc" "$HOME/.zshrc"
  copy_config "$DOTFILES_PATH/.zshenv" "$HOME/.zshenv"
  
  # Copiar archivos de configuración modular
  if [ -d "$DOTFILES_PATH/.zsh" ]; then
    run_command "cp -r $DOTFILES_PATH/.zsh/* $HOME/.zsh/" false
  fi
  
  # Clonar plugins necesarios
  clone_or_update_repo "https://github.com/Aloxaf/fzf-tab" "$HOME/.zsh/plugins/fzf-tab"
  clone_or_update_repo "https://github.com/Aloxaf/fzf-tab" "$DOTS_CONFIG_DIR/plugins/fzf-tab"
  
  # Configurar archivos personalizados
  create_custom_configs
  
  success_msg "Entorno ZSH configurado correctamente"
}

# Crear archivos de configuración personalizados
create_custom_configs() {
  # Archivos a crear y sus contenidos
  local configs=(
    "$DOTS_CONFIG_DIR/shell/zsh_custom.zsh:# Archivo para personalizaciones de ZSH\n# Este archivo se carga al final de .zshrc y no será sobrescrito en las actualizaciones\n\n# Agrega aquí tus personalizaciones, alias y funciones:"
    "$DOTS_CONFIG_DIR/terminal/tmux_custom.conf:# Configuración personalizada de Tmux\n# Este archivo se incluye desde .tmux.conf y no será sobrescrito\n\n# Agrega aquí tus personalizaciones:"
    "$DOTS_CONFIG_DIR/development/tools.sh:# Configuración de herramientas de desarrollo\n# Este archivo puede ser modificado para personalizar herramientas específicas"
    "$DOTS_CONFIG_DIR/development/projects.sh:# Configuración relacionada con proyectos\n# Define aquí paths a proyectos frecuentes o atajos para navegar entre ellos"
  )
  
  # Crear cada archivo si no existe
  for config in "${configs[@]}"; do
    IFS=':' read -r file content <<< "$config"
    if [ ! -f "$file" ]; then
      echo -e "$content" > "$file"
      success_msg "Creado archivo de configuración: $file"
    fi
  done
  
  # Copiar configuración de Oh-My-Posh
  copy_config "$DOTFILES_PATH/php.omp.json" "$DOTS_CONFIG_DIR/prompt/php.omp.json"
  
  # Actualizar permisos
  run_command "chmod -R u+w $DOTS_CONFIG_DIR" false
}

# Configurar Neovim
configure_neovim() {
  print_header "📝 Configurando Neovim"

  # Buscar la configuración de nvim en varias ubicaciones
  local nvim_locations=("./nvim" "$DOTFILES_PATH/nvim" "$HOME/pablo.dots/nvim")
  local nvim_source_dir=""
  
  for loc in "${nvim_locations[@]}"; do
    if [ -d "$loc" ] && [ "$(ls -A "$loc" 2>/dev/null)" ]; then
      nvim_source_dir="$loc"
      break
    fi
  done

  if [ -n "$nvim_source_dir" ]; then
    # Copiar configuración existente
    info_msg "Usando configuración de Neovim desde: $nvim_source_dir"
    ensure_dir "$NVIM_CONFIG_DIR"
    run_command "cp -rf $nvim_source_dir/* $NVIM_CONFIG_DIR/" false
    success_msg "Neovim configurado correctamente"
  else
    # Crear configuración básica
    info_msg "Creando una configuración básica de Neovim..."
    ensure_dir "$NVIM_CONFIG_DIR"
    cat > "$NVIM_CONFIG_DIR/init.lua" << 'EOL'
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
  fi
}

# Configurar Tmux
configure_tmux() {
  print_header "📟 Configurando Tmux"

  # Instalar tmux si es necesario
  if ! is_installed tmux; then
    install_apt_package "tmux"
  fi

  # Crear directorios necesarios
  ensure_dir "$TMUX_CONFIG_DIR/plugins"
  
  # Instalar Tmux Plugin Manager
  clone_or_update_repo "https://github.com/tmux-plugins/tpm" "$HOME/.tmux/plugins/tpm"
  
  # Copiar configuraciones
  copy_config "$DOTFILES_PATH/.tmux.conf" "$HOME/.tmux.conf"
  
  if [ -d "$DOTFILES_PATH/.tmux" ]; then
    run_command "cp -r $DOTFILES_PATH/.tmux/* $TMUX_CONFIG_DIR/" false
  fi

  # Instalar plugins (si tmux está disponible)
  if is_installed tmux; then
    # Cerrar sesión anterior si existe
    if tmux has-session -t $TMUX_SESSION_NAME 2>/dev/null; then
      tmux kill-session -t $TMUX_SESSION_NAME &>/dev/null
    fi
    
    # Crear nueva sesión e instalar plugins
    run_command "tmux new-session -d -s $TMUX_SESSION_NAME 'bash -c \"source ~/.tmux.conf && ~/.tmux/plugins/tpm/bin/install_plugins\"'" false
    
    # Esperar y cerrar sesión
    sleep 5
    if tmux has-session -t $TMUX_SESSION_NAME 2>/dev/null; then
      tmux kill-session -t $TMUX_SESSION_NAME &>/dev/null
    fi
  fi

  success_msg "Tmux configurado correctamente"
}

# Actualizar referencias en archivos de configuración
update_config_references() {
  print_header "🔄 Actualizando referencias en archivos de configuración"
  
  # Actualizar .zshrc
  if [ -f "$HOME/.zshrc" ] && ! grep -q "DOTS_CONFIG_DIR.*shell/zsh_custom.zsh" "$HOME/.zshrc"; then
    echo -e "\n# Cargar configuraciones personalizadas\nDOTS_CONFIG_DIR=\"\$HOME/dots.config\"\n[[ -f \"\$DOTS_CONFIG_DIR/shell/zsh_custom.zsh\" ]] && source \"\$DOTS_CONFIG_DIR/shell/zsh_custom.zsh\"" >> "$HOME/.zshrc"
  fi
  
  # Actualizar .tmux.conf
  if [ -f "$HOME/.tmux.conf" ] && ! grep -q "dots.config/terminal/tmux_custom.conf" "$HOME/.tmux.conf"; then
    echo -e "\n# Cargar configuración personalizada\nif-shell \"test -f ~/dots.config/terminal/tmux_custom.conf\" \"source ~/dots.config/terminal/tmux_custom.conf\"" >> "$HOME/.tmux.conf"
  fi
  
  # Actualizar archivo de prompt
  local prompt_file="$HOME/.zsh/tools/prompt.zsh"
  if [ -f "$prompt_file" ]; then
    sed -i 's|~/dots.config/php.opm.json|~/dots.config/prompt/php.omp.json|g' "$prompt_file"
  fi
  
  # Actualizar archivo dev.zsh
  local dev_file="$HOME/.zsh/tools/dev.zsh"
  if [ -f "$dev_file" ] && ! grep -q "dots.config/development/tools.sh" "$dev_file"; then
    echo -e "\n# Cargar configuraciones de desarrollo personalizadas\n[[ -f \"\$HOME/dots.config/development/tools.sh\" ]] && source \"\$HOME/dots.config/development/tools.sh\"\n[[ -f \"\$HOME/dots.config/development/projects.sh\" ]] && source \"\$HOME/dots.config/development/projects.sh\"" >> "$dev_file"
  fi
  
  success_msg "Referencias actualizadas correctamente"
}

# Establecer shell por defecto
set_default_shell() {
  print_header "🐚 Estableciendo shell por defecto"
  
  local shell_path=$(which zsh)
  if [ -n "$shell_path" ]; then
    # Añadir a /etc/shells si no existe
    grep -Fxq "$shell_path" /etc/shells || sudo sh -c "echo $shell_path >> /etc/shells"
    
    # Cambiar shell
    chsh -s "$shell_path" "$USER" &>/dev/null
    if [ $? -ne 0 ]; then
      run_command "sudo chsh -s $shell_path $USER" false
    fi
    
    success_msg "Shell cambiado a zsh correctamente"
  else
    error_msg "zsh no encontrado"
  fi
}

# Limpiar después de la instalación
cleanup() {
  print_header "🧹 Limpiando"
  
  # Asegurar permisos de Homebrew
  if is_installed brew; then
    run_command "sudo chown -R $(whoami) $(brew --prefix)/*" false
  fi
  
  # Volver al directorio original
  if [ -n "$ORIGINAL_DIR" ] && [ -d "$ORIGINAL_DIR" ]; then
    cd "$ORIGINAL_DIR"
  fi
  
  success_msg "Limpieza completada"
}

# =====================================================
# 🚀 FUNCIÓN PRINCIPAL
# =====================================================

main() {
  print_header "🚀 Iniciando instalación de dotfiles"
  
  # Guardar directorio original
  ORIGINAL_DIR=$(pwd)
  
  # Verificar si se ejecuta como root
  if [ "$(id -u)" -eq 0 ]; then
    error_msg "Este script no debe ser ejecutado como root"
    exit 1
  fi
  
  # Ejecutar pasos de instalación
  setup_directories
  install_basic_dependencies
  install_rust
  clone_dotfiles_repo
  install_homebrew_and_packages
  install_additional_tools
  configure_zsh_environment
  configure_neovim
  configure_tmux
  update_config_references
  set_default_shell
  cleanup
  
  print_header "🎉 ¡Instalación completada con éxito!"
  echo -e "${BOLD}${GREEN}Para aplicar todos los cambios, cierre y vuelva a abrir su terminal${RESET}"
  echo -e "${BOLD}${GREEN}O ejecute: exec zsh${RESET}"
  echo -e "${BOLD}${YELLOW}Personaliza tus configuraciones en: ${RESET}${BOLD}~/dots.config/${RESET}"
  
  # Iniciar zsh
  if is_installed zsh; then
    echo -e "\n${YELLOW}Iniciando nueva sesión de zsh...${RESET}"
    sleep 1
    exec zsh -l
  else
    echo -e "\n${RED}zsh no está disponible. Por favor instálelo e inicie una nueva sesión.${RESET}"
  fi
}

# Ejecutar función principal
main
