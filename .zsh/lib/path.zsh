#-----------------------------------------
# GESTIÓN DEL ENTORNO Y PATH
#-----------------------------------------
# Función helper para añadir directorios al PATH si existen
function append_path() {
  if [ -d "$1" ]; then
    [[ ":$PATH:" != *":$1:"* ]] && export PATH="$1:$PATH"
  fi
}

# Variables de entorno del sistema
export XDG_RUNTIME_DIR="$PREFIX/tmp/"  # Definir directorio de tiempo de ejecución XDG

# Configuración de PATH básico
append_path "$HOME/.local/bin"
