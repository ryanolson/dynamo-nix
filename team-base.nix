{ pkgs, ... }: {
  home = {
    stateVersion = "25.05";
  };

  # Core development tools
  home.packages = with pkgs; [
    # Language toolchains (managed independently)
    rustup          # Rust toolchain manager - allows independent updates
    python3         # Python interpreter
    zig             # Zig language
    nodejs_20       # Node.js runtime and npm package manager

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
    watchexec       # File watcher
    
    # Additional CLI tools from your config
    procs           # ps replacement
    du-dust         # du replacement (dust command)
    hyperfine       # Benchmarking tool
    sd              # sed replacement
    tokei           # Lines of code counter
    kondo           # Project cleanup tool
    
    # Language servers and formatters
    rust-analyzer   # Rust LSP
    clang-tools     # clang-format, clangd for C/C++
    gopls           # Go language server
    nodePackages.typescript-language-server  # TypeScript LSP
    nodePackages.vscode-langservers-extracted # HTML/CSS/JSON LSPs
    nodePackages.prettier  # Formatter for web languages
    ruff            # Python linter/formatter
    python311Packages.python-lsp-server  # Python LSP
    
    # Additional development tools
    sccache         # Compiler cache (for faster builds)
    cargo-edit      # Cargo extensions (cargo add, cargo rm, etc)
    cargo-watch     # Cargo file watcher
    
    # System administration tools
    docker          # Container runtime
    docker-compose  # Container orchestration
    kubectl         # Kubernetes CLI
    etcd            # Provides etcdctl command
    
    # Terminal and display
    # Note: ghostty not in nixpkgs yet, users install separately
  ];

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
        
        # Docker shortcuts
        d = "docker";
        dc = "docker-compose";
        
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
        
        # Add cargo to path (for rustup-managed tools)
        set -gx PATH $HOME/.cargo/bin $PATH
        
        # Install npm packages on first run if they don't exist
        if not type -q ccmanager
          echo "🔧 Installing ccmanager (Claude Code session manager)..."
          npm install -g ccmanager
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