#-----------------------------------------
# CONFIGURACIÓN PARA PHP/LARAVEL
#-----------------------------------------

# Agregar Composer al PATH
append_path "$HOME/.config/composer/vendor/bin"
append_path "$HOME/.config/herd-lite/bin"

# Aliases para Laravel
alias sail='sh $([ -f sail ] && echo sail || echo vendor/bin/sail)'  # Ejecutar Laravel Sail
alias pint='php $([ -f pint ] && echo pint || echo vendor/bin/pint)' # Ejecutar Laravel Pint
alias pa="php artisan"