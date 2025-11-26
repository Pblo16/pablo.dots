# Pablo.dots - AI Coding Agent Instructions

## Project Overview
This is a personal dotfiles repository for Linux terminal configuration, featuring:
- **Zsh** with modular configuration and Zinit plugin manager
- **Neovim** with LazyVim starter template and custom plugins
- **Development tools** setup via automated install script

## Key Architecture Patterns

### Modular Configuration Structure
- **Zsh**: Split into `~/.zsh/lib/` (core functions) and `~/.zsh/tools/` (feature modules)
- **Neovim**: LazyVim-based with extras in `lua/plugins/` for language support and AI integration
- **Centralized customizations**: `~/dots.config/` for user-specific overrides that persist across updates

### Installation & Setup

**System Dependencies (via apt):**
- build-essential, curl, file, git, zsh, lsd, unzip, p7zip, docker.io

**Development Tools:**
- Rust (via rustup)
- Homebrew packages: fnm, pnpm, neovim, gh, ripgrep, oh-my-posh, lazygit, zsh-autosuggestions, zsh-syntax-highlighting, fzf, go
- Additional tools: zoxide (smart cd), atuin (shell history), composer (PHP), docker configuration

**Configuration Setup:**
- Clones/configures Zsh plugins (fzf-tab, zsh-autosuggestions, fast-syntax-highlighting)
- Installs Zinit plugin manager
- Copies modular Zsh config to `~/.zsh/` (lib/, tools/, plugins/, completions/)
- Creates centralized config directory `~/dots.config/` with subdirectories for shell, prompt, terminal, development, backups
- Generates customizable config files (zsh_custom.zsh, tools.sh, projects.sh)
- Copies Neovim LazyVim config to `~/.config/nvim/`
- Changes default shell to Zsh and updates /etc/shells

The script is idempotent - it checks for existing installations and updates rather than reinstalling.

### Development Workflow Conventions

#### Neovim Configuration
- Uses LazyVim with custom plugins in `lua/plugins/`
- Copilot integration: `copilot.lua` disables suggestions/panel, `copilot-chat.lua` configures chat with Claude-3.7-sonnet
- Custom prompts defined in `copilot-chat.lua` for code explanation, review, testing, refactoring
- WSL clipboard fix in `config/lazy.lua` using win32yank

#### Zsh Customization
- Load modules via `load_module()` function in `.zshrc`
- Personal customizations go in `~/dots.config/shell/zsh_custom.zsh`
- Path management via `append_path()` helper in `lib/path.zsh`

### Key Files & Directories
- `install.sh`: Automated setup script (638 lines, handles dependencies and symlinks)
- `nvim/lua/plugins/`: Custom LazyVim plugins (avante, copilot-chat, laravel, etc.)
- `.zsh/lib/`: Core Zsh modules (path, aliases, functions, completions)
- `.zsh/tools/`: Feature modules (prompt, terminal, fzf, navigation, bindings)
- `~/dots.config/`: User customization directory created by install script


### Cross-Platform Considerations
- WSL-specific clipboard handling in Neovim config
- Homebrew setup for Linux with proper PATH configuration
- Rust and additional tools (zoxide, atuin) installed via install script</content>
<parameter name="filePath">/home/pablo/Projects/pablo.dots/.github/copilot-instructions.md