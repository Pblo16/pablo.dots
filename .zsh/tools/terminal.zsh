#-----------------------------------------
# INTEGRACIÓN CON WEZTERM
#-----------------------------------------
# Función para enviar el directorio de trabajo actual a WezTerm
function __wezterm_osc7() {
  if hash wezterm 2>/dev/null; then
    # Usar el comando auxiliar de WezTerm si está disponible
    wezterm set-working-directory 2>/dev/null && return
  fi
  # Alternativa: Enviar el directorio usando el protocolo OSC 7
  printf "\033]7;file://%s%s\033\\" "${HOSTNAME}" "${PWD}"
}

# Registrar la función para ejecutarse después de cada comando interactivo
precmd_functions+=(__wezterm_osc7)

#-----------------------------------------
# GESTOR DE VENTANAS (TMUX/ZELLIJ)
#-----------------------------------------
# Variables para el gestor de ventanas (actualmente tmux)
# WM_VAR="/$TMUX"     
# WM_CMD="tmux"        
## Inicia tmux/zellij automáticamente en sesiones interactivas
# function start_if_needed() {
#     # Si está en una sesión interactiva, no hay variable TMUX (no está en tmux) y es un terminal
#     if [[ $- == *i* ]] && [[ -z "$TMUX" ]] && [[ -t 1 ]]; then
#         # Intentar conectarse a sesión existente o crear una nueva si no existe
#         if tmux has-session 2>/dev/null; then
#             exec tmux attach
#         else
#             exec tmux
#         fi
#     fi
# }

# Iniciar gestor de ventanas (tmux/zellij) si es necesario
# start_if_needed
