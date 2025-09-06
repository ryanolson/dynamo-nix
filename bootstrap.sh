#!/bin/bash
set -euo pipefail

REPO_URL="github:ryanolson/dynamo-nix"
HM_BRANCH="release-25.05"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Check if running on supported system
if [[ "$OSTYPE" != "linux-gnu"* && "$OSTYPE" != "darwin"* ]]; then
    error "Unsupported operating system: $OSTYPE"
fi

log "🚀 Bootstrapping Dynamo development environment from $REPO_URL"

# Install system dependencies
log "📋 Installing system dependencies..."
if command -v apt-get &> /dev/null; then
    # Ubuntu/Debian
    sudo apt-get update -qq
    sudo apt-get install -y -qq xz-utils curl git
elif command -v yum &> /dev/null; then
    # RHEL/CentOS
    sudo yum install -y xz curl git
elif command -v brew &> /dev/null; then
    # macOS - dependencies usually available
    log "📦 macOS detected, dependencies should be available"
else
    warn "Unknown package manager - ensure xz, curl, and git are installed"
fi

# Install Nix if not present
if ! command -v nix &> /dev/null; then
    log "📦 Installing Nix package manager..."
    curl -L https://nixos.org/nix/install | sh || error "Failed to install Nix"
    
    # Source Nix profile
    if [[ -f ~/.nix-profile/etc/profile.d/nix.sh ]]; then
        . ~/.nix-profile/etc/profile.d/nix.sh
    else
        error "Nix installation completed but profile not found"
    fi
else
    log "📦 Nix already installed"
fi

# Enable flakes
log "⚙️  Configuring Nix flakes..."
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf

# Post-install setup instructions
log "🦀 Installing Rust toolchain (independent of Nix)..."
if ! command -v rustup &> /dev/null; then
    warn "Rustup not found in PATH. After setup completes, run:"
    warn "  rustup install stable"
    warn "  rustup default stable" 
    warn "  rustup component add rust-analyzer clippy rustfmt"
fi

# Bootstrap Home Manager  
log "🏠 Installing and configuring Home Manager..."

# Detect current user
CURRENT_USER=$(whoami)
log "Configuring for user: $CURRENT_USER"

# Clear any existing profile conflicts - more comprehensive cleanup
log "Cleaning up any existing profiles..."

# First, try to remove Home Manager profiles by pattern
if nix profile list 2>/dev/null | grep -q home-manager; then
    log "Found existing Home Manager profiles, removing them..."
    nix profile list 2>/dev/null | grep home-manager | while IFS= read -r line; do
        profile_num=$(echo "$line" | cut -d' ' -f1)
        log "Removing profile $profile_num: $line"
        nix profile remove "$profile_num" 2>/dev/null || true
    done
fi

# Also try removing by the exact flake reference that might conflict
nix profile remove "flake:home-manager/$HM_BRANCH#packages.x86_64-linux.default" 2>/dev/null || true
nix profile remove "home-manager/$HM_BRANCH" 2>/dev/null || true

# Clear home-manager state directories
log "Cleaning up Home Manager state directories..."
rm -rf ~/.local/state/home-manager 2>/dev/null || true
rm -rf ~/.local/state/nix/profiles/home-manager* 2>/dev/null || true

# Install Home Manager using the modern command
log "Installing Home Manager..."
nix profile install "nixpkgs#home-manager"

# Apply the dynamic configuration (works for any user)
log "Applying dynamic configuration for $CURRENT_USER..."
# Use --impure to allow environment variable access and create a temporary config
export HM_USER="$CURRENT_USER"
export HM_HOME="$HOME"
home-manager switch --flake $REPO_URL#default --no-write-lock-file --impure || error "Failed to setup Home Manager"

success "✅ Dynamo development environment setup complete!"
log "💡 Next steps:"
log "   1. Restart your shell or run: source ~/.nix-profile/etc/profile.d/nix.sh"
log "   2. If using Fish shell, run: fish"
log "   3. Install Rust toolchain: rustup install stable && rustup default stable"
log "   4. Add Rust components: rustup component add rust-analyzer clippy rustfmt"
log ""
log "🔧 Installed tools:"
log "   - Editors: helix, lazygit, GitHub CLI (gh)" 
log "   - Shell: fish, starship prompt, zellij multiplexer"
log "   - CLI: bat, eza, broot, zoxide, ripgrep, fd, yazi"
log "   - Languages: rustup, python3, zig, nodejs+npm"
log "   - System: docker, kubectl, etcdctl"
log "   - AI Tools: ccmanager (Claude Code manager), ruler (AI agent config)"
log ""
log "⚙️  All configuration files have been installed to ~/.config/"