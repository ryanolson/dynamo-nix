{ pkgs, ... }: {
  home = {
    stateVersion = "25.05";
  };

  # Core development tools
  home.packages = with pkgs; [
    # Language toolchains (managed independently)
    rustup          # Rust toolchain manager - allows independent updates
    uv              # Python package and version manager - Note: use 'home-manager switch' to update
    python3         # System Python3 (for build tools like node-gyp, not for projects)
    go              # Go language toolchain
    zig             # Zig language
    nodejs_22       # Node.js runtime and npm package manager (latest LTS)

    # Editors and shell
    helix           # Text editor
    fish            # Shell
    starship        # Shell prompt
    zellij          # Terminal multiplexer

    # Modern CLI replacements
    bat             # cat replacement  
    eza             # ls replacement
    broot           # tree replacement
    zoxide          # cd replacement with smart jumping
    ripgrep         # grep replacement
    fd              # find replacement
    
    # Git tools
    lazygit         # Terminal UI for git
    gh              # GitHub CLI
    
    # File management
    yazi            # Terminal file manager
    
    # Development tools
    just            # Command runner (make replacement)
    bacon           # Rust-specific continuous testing tool
    watchexec       # General file watcher
    
    # Additional CLI tools from your config
    procs           # ps replacement
    du-dust         # du replacement (dust command)
    hyperfine       # Benchmarking tool
    sd              # sed replacement
    tokei           # Lines of code counter
    kondo           # Project cleanup tool
    
    # Language servers and formatters
    # rust-analyzer provided by rustup components
    clang-tools     # clang-format, clangd for C/C++
    gopls           # Go language server
    nodePackages.typescript-language-server  # TypeScript LSP
    nodePackages.vscode-langservers-extracted # HTML/CSS/JSON LSPs
    nodePackages.prettier  # Formatter for web languages
    
    # Additional development tools
    sccache         # Compiler cache (for faster builds)
    cargo-edit      # Cargo extensions (cargo add, cargo rm, etc)
    cargo-watch     # Cargo file watcher
    
    # Build tools for npm packages with native dependencies
    gcc             # C compiler for node-gyp
    gnumake         # Make for building native modules
    
    # System administration tools
    kubectl         # Kubernetes CLI
    etcd            # Provides etcdctl command
    
    # Terminal and display
    # Note: ghostty not in nixpkgs yet, users install separately
  ];

  # Custom scripts
  home.file.".local/bin/dynamo-update-tools" = {
    text = ''
      #!/usr/bin/env fish

      # Dynamo Development Environment Update Script
      # Updates all development tools and configurations

      set -g RED '\033[0;31m'
      set -g GREEN '\033[0;32m'
      set -g BLUE '\033[0;34m'
      set -g YELLOW '\033[1;33m'
      set -g NC '\033[0m' # No Color

      function log
          echo -e "$BLUE[INFO]$NC $argv"
      end

      function success
          echo -e "$GREEN[SUCCESS]$NC $argv"
      end

      function warn
          echo -e "$YELLOW[WARN]$NC $argv"
      end

      function error
          echo -e "$RED[ERROR]$NC $argv"
      end

      function help
          echo "Dynamo Development Environment Update Tool"
          echo ""
          echo "Usage: dynamo-update-tools [OPTIONS]"
          echo ""
          echo "Options:"
          echo "  --all, -a       Update everything (default)"
          echo "  --nix           Update Nix packages via Home Manager"
          echo "  --rust          Update Rust toolchain via rustup"
          echo "  --npm           Update global npm packages"
          echo "  --config        Update team configuration from GitHub"
          echo "  --help, -h      Show this help message"
          echo ""
          echo "Examples:"
          echo "  dynamo-update-tools           # Update everything"
          echo "  dynamo-update-tools --rust    # Update only Rust toolchain"
          echo "  dynamo-update-tools --nix     # Update only Nix packages"
      end

      # Parse command line arguments
      set update_all true
      set update_nix false
      set update_rust false
      set update_npm false
      set update_config false

      for arg in $argv
          switch $arg
              case '--all' '-a'
                  set update_all true
              case '--nix'
                  set update_all false
                  set update_nix true
              case '--rust'
                  set update_all false
                  set update_rust true
              case '--npm'
                  set update_all false
                  set update_npm true
              case '--config'
                  set update_all false
                  set update_config true
              case '--help' '-h'
                  help
                  exit 0
              case '*'
                  error "Unknown option: $arg"
                  help
                  exit 1
          end
      end

      # If --all or no specific flags, enable all updates
      if test $update_all = true
          set update_nix true
          set update_rust true
          set update_npm true
          set update_config true
      end

      log "🚀 Starting Dynamo development environment updates..."

      set update_errors 0

      # Update Home Manager / Nix packages
      if test $update_nix = true
          log "📦 Updating Nix packages via Home Manager..."
          if home-manager switch
              success "✅ Nix packages updated successfully"
          else
              error "❌ Failed to update Nix packages"
              set update_errors (math $update_errors + 1)
          end
      end

      # Update Rust toolchain
      if test $update_rust = true
          log "🦀 Updating Rust toolchain..."
          if rustup update
              success "✅ Rust toolchain updated successfully"
              
              # Update Rust components
              log "🔧 Updating Rust components..."
              if rustup component add rust-analyzer clippy rustfmt
                  success "✅ Rust components updated successfully"
              else
                  warn "⚠️  Some Rust components may have failed to update"
              end
          else
              error "❌ Failed to update Rust toolchain"
              set update_errors (math $update_errors + 1)
          end
      end

      # Update global npm packages
      if test $update_npm = true
          log "📦 Updating global npm packages..."
          
          set npm_packages ccmanager @anthropic-ai/claude-code @intellectronica/ruler
          
          for pkg in $npm_packages
              log "Updating $pkg..."
              if npm update -g $pkg
                  success "✅ Updated $pkg"
              else
                  warn "⚠️  Failed to update $pkg (may not be installed)"
              end
          end
          
          success "✅ Global npm packages update completed"
      end

      # Update team configuration
      if test $update_config = true
          log "⚙️  Updating team configuration..."
          if home-manager switch --flake github:ryanolson/dynamo-nix
              success "✅ Team configuration updated successfully"
          else
              error "❌ Failed to update team configuration"
              set update_errors (math $update_errors + 1)
          end
      end

      # Summary
      if test $update_errors -eq 0
          success "🎉 All updates completed successfully!"
          log "💡 Tip: Restart your shell or run 'exec fish' to ensure all updates are active"
      else
          warn "⚠️  Updates completed with $update_errors errors"
          log "💡 Check the output above for details on any failures"
      end

      exit $update_errors
    '';
    executable = true;
  };

  # Configuration files
  home.file = {
    # Helix editor configuration
    ".config/helix/config.toml".source = ./config/helix/config.toml;
    ".config/helix/languages.toml".source = ./config/helix/languages.toml;
    ".config/helix/yazi-picker.sh".source = ./config/helix/yazi-picker.sh;
    
    # Starship prompt configuration
    ".config/starship.toml".source = ./config/starship/starship.toml;
    
    # Zellij terminal multiplexer configuration
    ".config/zellij/config.kdl".source = ./config/zellij/config.kdl;
    
    # Ghostty terminal configuration
    ".config/ghostty/config".source = ./config/ghostty/config;
    
    # Broot file manager configuration
    ".config/broot/conf.hjson".source = ./config/broot/conf.hjson;
    ".config/broot/verbs.hjson".source = ./config/broot/verbs.hjson;
    ".config/broot/skins".source = ./config/broot/skins;
  };

  # Configure programs
  programs = {
    helix.enable = true;
    
    fish = {
      enable = true;
      # Shell aliases (no personal info here)
      shellAliases = {
        # Core replacements
        cat = "bat";
        ls = "eza";
        l = "eza";
        tree = "broot";
        c = "z";  # zoxide jump
        
        # Development shortcuts  
        h = "hx";  # helix
        
        # Kubernetes
        k = "kubectl";
        
        # System tools
        e = "etcdctl";
      };
      
      # Initialize tools that need shell integration
      shellInit = ''
        # Initialize zoxide for smart cd
        zoxide init fish | source
        
        # Initialize starship prompt
        starship init fish | source
        
        # Set up colors
        set -x COLORTERM truecolor
        
        # Add local bin to path (for custom scripts)
        set -gx PATH $HOME/.local/bin $PATH
        
        # Add cargo to path (for rustup-managed tools)
        set -gx PATH $HOME/.cargo/bin $PATH
        
        # Configure npm to use user directory for global packages
        set -gx NPM_CONFIG_PREFIX $HOME/.npm-global
        set -gx PATH $HOME/.npm-global/bin $PATH
        mkdir -p $HOME/.npm-global
        
        # Set up Rust toolchain if not configured
        if not rustup show active-toolchain &>/dev/null
          echo "🦀 Setting up Rust stable toolchain..."
          rustup install stable
          rustup default stable
          rustup component add rust-analyzer clippy rustfmt
        end
        
        # Install npm packages on first run if they don't exist
        if not type -q ccmanager
          echo "🔧 Installing ccmanager (Claude Code session manager)..."
          npm install -g ccmanager
        end
        
        if not type -q claude-code
          echo "🔧 Installing claude-code (Claude AI CLI)..."
          npm install -g @anthropic-ai/claude-code
        end
        
        if not type -q ruler
          echo "🔧 Installing ruler (AI agent configuration manager)..."
          npm install -g @intellectronica/ruler
        end
      '';
    };
    
    starship.enable = true;
    
    # Enable git (but no personal config in team base)
    git.enable = true;
    
    # Enable GitHub CLI
    gh.enable = true;
    
    # Enable Home Manager to manage itself
    home-manager.enable = true;
  };
}