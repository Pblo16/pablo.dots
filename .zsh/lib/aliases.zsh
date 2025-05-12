#-----------------------------------------
# ALIAS Y FUNCIONES BÁSICAS
#-----------------------------------------
# Aliases para navegación y listado de directorios
# Utiliza 'lsd' como reemplazo mejorado del comando 'ls' estándar
alias ls='lsd'                    # Mostrar listado básico con lsd (alternativa moderna a ls)
alias la='ls -a'                  # Mostrar archivos y directorios ocultos (incluyendo . y ..)
alias lla='ls -la'                # Mostrar listado detallado incluyendo archivos ocultos
alias lt='ls --tree'              # Mostrar estructura de directorios en formato árbol

# Aliases para desarrollo y editores
alias n='nvim .'                  # Abrir Neovim en el directorio actual
alias pj='cd ~/Projects && ls'    # Navegar al directorio de proyectos y listar su contenido
alias vc='code --reuse-window .'  # Abrir VSCode en la ventana actual para el directorio actual
