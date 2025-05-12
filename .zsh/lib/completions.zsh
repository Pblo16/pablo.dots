#-----------------------------------------
# MEJORAS DE COMPLETADO Y VISUALIZACIÓN
#-----------------------------------------
# Agregar rutas adicionales para definiciones de autocompletado
fpath+=($(brew --prefix 2>/dev/null)/share/zsh/site-functions)  # Autocompletados de Homebrew
fpath+=(~/.zsh/completions)                                     # Autocompletados personalizados

# Recargar sistema de autocompletado
autoload -Uz compinit && compinit -u

# Estilo y comportamiento de autocompletado
zstyle ':completion:*' menu select              # Menú de selección para autocompletado
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" # Colorear autocompletado
