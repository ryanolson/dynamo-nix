# Dynamo Team Development Environment

A Nix + Home Manager configuration for consistent development environments across the team.

## Quick Setup

Fresh machine? Run this one-liner:

```bash
curl -fsSL https://raw.githubusercontent.com/dynamo/nix/main/bootstrap.sh | bash
```

## What You Get

### Core Tools
- **Rust** - `rustup` for toolchain management (independent updates)
- **Python** - Python 3 interpreter + modern tooling
- **Zig** - Zig language and tools
- **Node.js** - Node.js runtime + npm package manager

### Editors & Shell
- **Helix** - Modern modal text editor with LSP support
- **Fish** - User-friendly shell with sensible defaults
- **Starship** - Fast, customizable shell prompt
- **Zellij** - Terminal multiplexer (tmux alternative)

### Modern CLI Tools
- **bat** - `cat` with syntax highlighting
- **eza** - `ls` replacement with colors and icons
- **broot** - `tree` replacement with navigation
- **zoxide** - `cd` replacement with smart jumping  
- **ripgrep** - `grep` replacement (faster)
- **fd** - `find` replacement (faster)
- **yazi** - Terminal file manager

### Development Support
- **Language Servers** - rust-analyzer, clangd, gopls, pylsp, ruff
- **Git Tools** - lazygit terminal UI, GitHub CLI (gh)
- **System Tools** - docker, kubectl, etcdctl
- **Formatters** - prettier, clang-format, rustfmt
- **AI Tools** - ccmanager (Claude Code session manager), ruler (AI agent rule config)

### Configurations Included
All tools come pre-configured with sensible defaults:
- Helix with Catppuccin theme, LSP support, key bindings
- Fish shell with useful aliases
- Starship prompt with Git integration
- Zellij with custom key bindings
- Broot file navigation

## Personal Customization

This is the **team base configuration**. For personal customizations:

1. Create your own dotfiles repository
2. Import this configuration as a base
3. Add your personal git config, SSH keys, etc.

See the [personal setup guide](../dynamo-dotfiles/README.md) for details.

## Manual Setup

If you prefer to run commands individually:

```bash
# Install Nix
curl -L https://nixos.org/nix/install | sh
source ~/.nix-profile/etc/profile.d/nix.sh

# Enable flakes
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf

# Setup environment
nix run home-manager/release-25.05 -- init --switch --flake github:dynamo/nix
```

## Post-Setup

After installation:

1. **Restart your shell** or run: `source ~/.nix-profile/etc/profile.d/nix.sh`
2. **Install Rust toolchain**: `rustup install stable && rustup default stable`
3. **Add Rust components**: `rustup component add rust-analyzer clippy rustfmt`

## Updates

To update your environment:

```bash
home-manager switch --flake github:dynamo/nix
```

## Language Toolchain Independence

- **Rust**: Managed by rustup - update with `rustup update`
- **Python**: Use `uv` or `pip` for project dependencies  
- **Zig**: Managed by Nix - updates with `home-manager switch`

This ensures language toolchains can be updated independently of the Nix configuration.

## Requirements

- **OS**: macOS or Linux
- **Nix**: Installed automatically by bootstrap script
- **Disk**: ~2GB for initial Nix store
- **Network**: Internet connection for package downloads

## Troubleshooting

### Command not found after setup
- Restart your shell: `exec $SHELL`
- Or source Nix profile: `source ~/.nix-profile/etc/profile.d/nix.sh`

### Rust tools not working
- Install Rust toolchain: `rustup install stable && rustup default stable`
- The bootstrap script installs rustup but you choose your Rust version

### Language servers not working in Helix
- All LSPs are pre-installed and configured
- Check `:lsp-workspace-command` in Helix for debugging