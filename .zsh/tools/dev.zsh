#-----------------------------------------
# CONFIGURACIÓN PARA ENTORNOS DE DESARROLLO
#-----------------------------------------

#========= HERRAMIENTAS ADICIONALES =========
# Turso
append_path "$HOME/.turso"

# Otras herramientas de desarrollo
if command -v lazygit &>/dev/null; then
  alias lg="lazygit"
fi

# Utilidades de bases de datos
alias pg="psql"
alias my="mysql"

# Cargar configuraciones de desarrollo personalizadas
[[ -f "$HOME/dots.config/development/tools.sh" ]] && source "$HOME/dots.config/development/tools.sh"
[[ -f "$HOME/dots.config/development/projects.sh" ]] && source "$HOME/dots.config/development/projects.sh"
