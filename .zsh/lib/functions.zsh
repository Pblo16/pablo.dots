#-----------------------------------------
# FUNCIONES ÚTILES
#-----------------------------------------
# Función para crear un directorio y entrar inmediatamente
function mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Función para extraer archivos comprimidos de diferentes formatos
function extract() {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1    ;;
      *.tar.gz)    tar xzf $1    ;;
      *.bz2)       bunzip2 $1    ;;
      *.rar)       unrar e $1    ;;
      *.gz)        gunzip $1     ;;
      *.tar)       tar xf $1     ;;
      *.tbz2)      tar xjf $1    ;;
      *.tgz)       tar xzf $1    ;;
      *.zip)       unzip $1      ;;
      *.Z)         uncompress $1 ;;
      *.7z)        7z x $1       ;;
      *)           echo "'$1' no puede ser extraído automáticamente" ;;
    esac
  else
    echo "'$1' no es un archivo válido"
  fi
}
