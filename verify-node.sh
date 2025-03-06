#!/bin/bash

# Source zshrc in a bash-compatible way
source <(grep -v "^autoload\|^compdef\|^setopt\|^zstyle" "$HOME/.zshrc")

echo "=== Environment Verification ==="

echo -n "Node version: "
node --version || echo "Node not found in PATH!"

echo -n "npm version: "
npm --version || echo "npm not found in PATH!"

echo -n "pnpm version: "
pnpm --version || echo "pnpm not found in PATH!"

echo -n "fnm version: "
fnm --version || echo "fnm not found in PATH!"

echo -e "\n=== PATH Analysis ==="
echo "$PATH" | tr ':' '\n' | grep -E 'node|npm|pnpm|fnm'

echo -e "\n=== Current Node Location ==="
which node || echo "Node binary not found"

echo -e "\n=== fnm Configurations ==="
fnm list

echo -e "\n=== Directory Permissions ==="
ls -la "/run/user/$(id -u)/" | grep fnm
