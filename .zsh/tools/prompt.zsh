#-----------------------------------------
# CONFIGURACIÓN DE PROMPT Y ASPECTO VISUAL
#-----------------------------------------

# Oh-my-posh para prompt personalizado
if command -v oh-my-posh &>/dev/null; then
  # Verificar si existe el archivo de configuración
  if [[ -f ~/dots.config/prompt/php.omp.json ]]; then
    eval "$(oh-my-posh init zsh --config ~/dots.config/prompt/php.omp.json)"
  elif [[ -f ~/dots.config/prompt/php.omp.json ]]; then
    # Búsqueda en ubicación antigua para compatibilidad
    eval "$(oh-my-posh init zsh --config ~/dots.config/prompt/php.omp.json)"
  else
    # Usar tema predeterminado si no existe el personalizado
    eval "$(oh-my-posh init zsh)"
  fi
fi
