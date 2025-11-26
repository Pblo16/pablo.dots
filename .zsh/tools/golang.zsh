#-----------------------------------------
# CONFIGURACIÓN PARA GO
#-----------------------------------------

if command -v go &>/dev/null; then
  export GOPATH="$HOME/gocode"
  append_path "$GOPATH/bin"
fi