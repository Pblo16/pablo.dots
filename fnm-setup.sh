#!/bin/bash

# Ensure fnm directories exist with proper permissions
mkdir -p "$HOME/.local/share/fnm"
mkdir -p "/run/user/$(id -u)/fnm_multishells"

# Check if fnm is installed, install it if not
if ! command -v fnm &> /dev/null; then
    echo "Installing fnm..."
    curl -fsSL https://fnm.vercel.app/install | bash
fi

# Ensure we have at least one Node.js version installed
echo "Setting up Node.js versions..."
source "$HOME/.zshrc"
fnm use default || fnm install --lts

echo "fnm setup complete. Please restart your terminal or run 'exec zsh'"
