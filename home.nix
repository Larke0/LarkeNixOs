# =============================================================================
# HOME MANAGER CONFIGURATION (home.nix)
# =============================================================================
# Version Tracker: VERSION 10
# This file manages user-level environment, dotfiles, and applications 
# declaratively. Updates take effect via your 'rebuild' shell alias.
# =============================================================================

{ config, pkgs, inputs, lib, ... }:

let
  # ---------------------------------------------------------------------------
  # Local Variables & Helper Functions (Let Block)
  # ---------------------------------------------------------------------------
  
  # Lists of common media MIME types used to batch-assign default applications
  # instead of writing a repetitive line for every single file extension.
  videoTypes = [
    "video/mp4"
    "video/x-matroska" # .mkv
    "video/webm"
    "video/quicktime"  # .mov
    "video/x-msvideo"  # .avi
    "video/x-flv"
    "video/ogg"
  ];

  imageTypes = [
    "image/png"
    "image/jpeg"        # .jpg / .jpeg
    "image/gif"
    "image/webp"
    "image/svg+xml"
    "image/bmp"
    "image/tiff"
  ];

  # Short helper alias for generating out-of-store symbolic links.
  # This tells Home Manager to link directly to your local repository rather than 
  # copying files into the immutable, read-only Nix store (/nix/store).
  # Crucial for live-editing dotfiles without needing a full system rebuild.
  link = config.lib.file.mkOutOfStoreSymlink;

  # Absolute path to your tracked dotfiles git repository.
  repo = "${config.home.homeDirectory}/Larke-shell";
in

{
  # ---------------------------------------------------------------------------
  # User Profile & Environment Core
  # ---------------------------------------------------------------------------
  home.username = "larke";
  home.homeDirectory = "/home/larke";
  
  # Home Manager Release Version. This ensures backwards compatibility with internal 
  # module changes. Do not change unless you intend to migrate your state files.
  home.stateVersion = "25.11";
  
  # ---------------------------------------------------------------------------
  # Core Applications & Shell Configurations
  # ---------------------------------------------------------------------------

  # Declarative Git configuration for user tracking
  programs.git = {
    enable = true;
    settings.user.name = "Larke0";
    settings.user.email = "larke850@gmail.com";
  };
  
  # Fish Shell Configuration
  programs.fish = {
    enable = true;
    
    # Logic loaded into every interactive terminal session
    interactiveShellInit = ''
        # Initialize and load Starship prompt styling
        starship init fish | source
        
        # Enable transient prompt support (hides old prompts upon hitting enter 
        # to maximize terminal vertical scannability)
        function starship_transient_prompt_func
            starship module character
        end
        enable_transience
        
        # Mute the default greeting banner for a clean look
        set -g fish_greeting
    '';
    
    # Custom functions that behave like scripts but compile natively in shell memory
    functions = {
        # Quick inline terminal calculator using SageMath
        calc = "sage -c \"print($argv)\"";
    }; 
    
    # Terminal shorthand commands mapped to long utilities
    shellAliases = {
      btw = "echo I use nixos, btw";
      
      # Rebuild and apply the entire system configuration profile from your local flake setup
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#(hostname)";
      
      # Execute custom theme-compliant wallpaper daemon script
      set-wallpaper = "~/.config/quickshell/scripts/set-wallpaper.sh";
      
      # Hard reset local repo with GitHub's main branch, fix shebangs to match Nix runtime path standards, and make runnable
      sync-dots = "cd ~/Larke-shell && ${pkgs.git}/bin/git fetch --all && ${pkgs.git}/bin/git reset --hard origin/main && find ~/Larke-shell -name '*.sh' -exec sed -i 's|#!/bin/bash|#!/usr/bin/env bash|g' {} \\; && find ~/Larke-shell -name '*.sh' -exec chmod +x {} \\;";
      
      # Stages all untracked file changes inside dotfiles directory, commits, and pushes them safely to GitHub
      push-dots = "cd ~/Larke-shell && git add -A && git commit -m 'update dots' && git push";
      
      zen-browser = "zen";
      
      # Wrapper to handle system-level Git updates inside the restricted /etc/nixos profile utilizing your secure user SSH keys
      ngit = "sudo GIT_SSH_COMMAND='ssh -i /home/larke/.ssh/id_ed25519' git -C /etc/nixos";
    };
  };
  
  # ---------------------------------------------------------------------------
  # Declarative XDG Config Symlinking (The Native Nix Way)
  # ---------------------------------------------------------------------------
  # Home Manager directly maps these definitions to path targets in ~/.config. 
  # Old/dead entries are tracked, safely deleted, and handled automatically.
  xdg.configFile = {
    # Full Desktop/Terminal Environments Managed Directly
    "quickshell".source = link "${repo}/.config/quickshell";
    "nvim".source       = link "${repo}/.config/nvim";
    "matugen".source    = link "${repo}/.config/matugen";
    "kitty".source      = link "${repo}/.config/kitty";
    "fastfetch".source  = link "${repo}/.config/fastfetch";
    "rofi".source       = link "${repo}/.config/rofi";
    "qt6ct".source      = link "${repo}/.config/qt6ct";
    "Kvantum".source    = link "${repo}/.config/Kvantum";
    "btop".source       = link "${repo}/.config/btop";

    # Hyprland Window Manager Architecture Modules
    "hypr/hyprland".source      = link "${repo}/.config/hypr/hyprland";
    "hypr/scripts".source       = link "${repo}/.config/hypr/scripts";
    "hypr/GameWorkspace".source = link "${repo}/.config/hypr/GameWorkspace";

    # Hyprland Root Core Configuration Files (Swapped to Lua)
    "hypr/hyprland.lua".source  = link "${repo}/.config/hypr/hyprland.lua";
    "hypr/hypridle.conf".source = link "${repo}/.config/hypr/hypridle.conf";
    "hypr/hyprlock.conf".source = link "${repo}/.config/hypr/hyprlock.conf";
    "hypr/xdph.conf".source     = link "${repo}/.config/hypr/xdph.conf";
    "hypr/custom/hyprland.lua.example".source = link "${repo}/.config/hypr/custom/hyprland.lua.example";

    # Desktop Toolkits Style Standard Overrides (GTK Theme Settings)
    "gtk-3.0/settings.ini".source = link "${repo}/.config/gtk-3.0/settings.ini";
    "gtk-4.0/settings.ini".source = link "${repo}/.config/gtk-4.0/settings.ini";
    
    # Starship Shell Prompt Configuration
    "starship.toml".source = link "${repo}/.config/starship.toml";
  };

  # ---------------------------------------------------------------------------
  # Desktop Environment & Theme Settings (Gsettings / Dconf)
  # ---------------------------------------------------------------------------
  # Sets environment settings natively into the user's dconf database layout,
  # ensuring GTK apps fall back correctly onto dark styles and uniform assets.
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      gtk-theme = "adw-gtk3-dark";
      color-scheme = "prefer-dark";
      icon-theme = "Papirus-Dark";
      cursor-theme = "Bibata-Modern-Classic";
      cursor-size = lib.hm.gvariant.mkInt32 24; # Explicitly typed 32-bit integer for GNOME API compatibility
    };
  };
  
  # ---------------------------------------------------------------------------
  # Imperative Activation Scripts (Fallback Hooks)
  # ---------------------------------------------------------------------------
  # Runs after the configuration state has been calculated and written (`writeBoundary`).
  # This hook handles items that *must* execute directly on the actual file system, 
  # such as cloning networks or preparing placeholder tracking logs.
  home.activation.cloneDotfiles = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    # Bootstrapping: Clone your dotfiles repository if a clean install is detected
    if [ ! -d "$HOME/Larke-shell" ]; then
      ${pkgs.git}/bin/git clone https://github.com/Larke0/Larke-shell "$HOME/Larke-shell"
    else
      # Pull fresh files to verify configuration sync matches upstream master repository
      cd "$HOME/Larke-shell" && ${pkgs.git}/bin/git fetch --all && ${pkgs.git}/bin/git reset --hard origin/main || echo "GIT PULL FAILED" 
    fi
    
    # Fix absolute execution schemas for portability across NixOS shell environments
    find "$HOME/Larke-shell/" -name "*.sh" -exec sed -i 's|#!/bin/bash|#!/usr/bin/env bash|g' {} \;
    find "$HOME/Larke-shell/" -name "*.sh" -exec chmod +x {} \; 
    
    # Ensure localized system configuration directories and dynamically managed theme files 
    # exist so Hyprland components can write to them immediately upon initialization
    mkdir -p "$HOME/.config/hypr/hyprland"
    mkdir -p "$HOME/.config/hypr/custom"
    touch "$HOME/.config/hypr/hyprland/theme.conf"
    touch "$HOME/.config/hypr/custom/hyprland.conf"
  '';

  # ---------------------------------------------------------------------------
  # XDG Client Applications & File Associations
  # ---------------------------------------------------------------------------
  xdg.mimeApps = {
    enable = true;
    defaultApplications = 
    # 'genAttrs' takes an array of extensions and dynamically generates matching 
    # target properties mapping them all cleanly to specific viewer desktops.
    (lib.genAttrs videoTypes (_: "org.kde.haruna.desktop")) // # Maps all videoTypes to Haruna Media Player
    (lib.genAttrs imageTypes (_: "org.kde.gwenview.desktop")) // # Maps all imageTypes to Gwenview Image Viewer
    {
      "inode/directory" = "org.gnome.Nautilus.desktop";
      "text/plain" = "nvim-kitty.desktop";
      "x-scheme-handler/http" = "helium.desktop";
      "x-scheme-handler/https" = "helium.desktop";
      "x-scheme-handler/about" = "helium.desktop";
      "x-scheme-handler/unknown" = "helium.desktop";
      "application/zip" = "org.gnome.Nautilus.desktop";
    };
  };

  # Custom app menu listings wrapper definitions (.desktop generator)
  xdg.desktopEntries = {
    # Custom desktop entry launcher to force Neovim to load up natively inside a Kitty instance
    nvim-kitty = {
      name = "Neovim";
      exec = "kitty nvim %F";
      terminal = false;
      mimeType = [ "text/plain" ];
    };

    # Web app instance shorthand target grouping for YouTube Music running inside Helium
    ytmusic = {
      name = "Youtube Music";
      exec = "helium --app=https://music.youtube.com/";
      terminal = false;
      icon = "youtube-music";
    };
  };

  # ---------------------------------------------------------------------------
  # User Directory Standards Configuration
  # ---------------------------------------------------------------------------
  # Explicitly standardizes location setups for personal folders to guarantee apps 
  # don't create unorganized directories randomly inside the primary home directory.
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop     = "${config.home.homeDirectory}/Desktop";
    documents   = "${config.home.homeDirectory}/Documents";
    download    = "${config.home.homeDirectory}/Downloads";
    music       = "${config.home.homeDirectory}/Music";
    pictures    = "${config.home.homeDirectory}/Pictures";
    videos      = "${config.home.homeDirectory}/Videos";
    templates   = "${config.home.homeDirectory}/Templates";
    publicShare = "${config.home.homeDirectory}/Public";
  };

  # ---------------------------------------------------------------------------
  # Package sandboxing support structures (Flatpak Integration)
  # ---------------------------------------------------------------------------
  services.flatpak = {
    enable = true;
    packages = [
        "io.github.kolunmi.Bazaar" # System Flatpak app injection hook
    ];
  };

  # ---------------------------------------------------------------------------
  # Flake Extensions & External Home Manager Modules Loading
  # ---------------------------------------------------------------------------
  imports = [
      inputs.nixcord.homeModules.nixcord          # Discord styling framework extension module
      inputs.spicetify-nix.homeManagerModules.default # Spotify custom optimization client expansion module
  ];

  # ---------------------------------------------------------------------------
  # Extension Module Configuration: Nixcord (Discord Setup)
  # ---------------------------------------------------------------------------
  programs.nixcord = {
    enable = true;
    
    # Core framework settings
    discord = {
      vencord.enable = true;  # Enable Vencord plugin client runtime injection
      openASAR.enable = true; # Open-source lightweight Discord client layout optimizations
    };
    
    # Custom interface overrides styling insertion zone
    quickCss = "/* css goes here */";
    
    config = {
      useQuickCss = true;
      themeLinks = [
        "https://capnkitten.github.io/BetterDiscord/Themes/Material-Discord/css/source.css"
      ];
      frameless = true; # Strip decoration borders off system graphical client structures

      # Declarative Plugin Activation Engine Flags
      plugins = {
        betterGifPicker.enable = true;
        favoriteGifSearch.enable = true;
        gifPaste.enable = true;
        petpet.enable = true;
        imageZoom.enable = true;
        betterGifAltText.enable = true;
        callTimer.enable = true;
        copyEmojiMarkdown.enable = true;
        crashHandler.enable = true;
        disableCallIdle.enable = true;
        fixImagesQuality.enable = true;
        fixSpotifyEmbeds.enable = true;
        fixYoutubeEmbeds.enable = true;
        friendsSince.enable = true;
        fullSearchContext.enable = true;
        gameActivityToggle.enable = true;
        greetStickerPicker.enable = true;
        mentionAvatars.enable = true;
        messageLogger.enable = true;
        noF1.enable = true;
        notificationVolume.enable = true;
        OnePingPerDM.enable = true;
        openInApp.enable = true;
        silentTyping.enable = true;
        spotifyCrack.enable = true;
        translate.enable = true;
        volumeBooster.enable = true;
        voiceMessages.enable = true;
        youtubeAdblock.enable = true;
      };
    };
  };

  # ---------------------------------------------------------------------------
  # Extension Module Configuration: Spicetify (Spotify Customization)
  # ---------------------------------------------------------------------------
  programs.spicetify =
    let
      # Point to package evaluation structures compiled by the spicetify flake input layer
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      enable = true;

      # Function patches to append directly to the target Spotify running audio instance
      enabledExtensions = with spicePkgs.extensions; [
        adblock
        hidePodcasts
        shuffle
        catJamSynced
        beautifulLyrics
      ];
      
      # Additional pages to register into Spotify's sidebar
      enabledCustomApps = with spicePkgs.apps; [
        newReleases
        ncsVisualizer
      ];
      
      # Targeted script pieces to overwrite app behavior
      enabledSnippets = with spicePkgs.snippets; [
        rotatingCoverart
        pointer
      ];

      # Graphical styling template assignment selection
      theme = spicePkgs.themes.dribbblishDynamic;
  };
}
