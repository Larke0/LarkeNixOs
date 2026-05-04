# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, pkgs-unstable, inputs, ... }:

{
  

  ###################
  ### BOOT        ###
  ###################

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.consoleMode = "max";
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  #boot.kernelPackages = inputs.nix-cachyos-kernel.legacyPackages.x86_64-linux.linuxPackages-cachyos-latest;

  
 
  boot.plymouth = {
    enable = true;
    theme = "nixos-bgrt";
    themePackages = [ pkgs.nixos-bgrt-plymouth ];
  };

  boot.initrd.systemd.enable = true;

  boot.kernelParams = [
    "quiet"
    "splash"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
    "video=1920x1080@60"
  ];

  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;

  # TPM
  security.tpm2.enable = true;
  security.tpm2.pkcs11.enable = true;
  security.tpm2.tctiEnvironment.enable = true;

  ###################
  ### NETWORKING  ###
  ###################

  networking.networkmanager.enable = true;

  ###################
  ### LOCALE      ###
  ###################

  time.timeZone = "America/Fortaleza";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "br-abnt2";
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
      qt6Packages.fcitx5-qt
      qt6Packages.fcitx5-configtool
    ];
  };

  ###################
  ### DISPLAY     ###
  ###################

  services.xserver = {
    enable = true;
    autoRepeatDelay = 200;
    autoRepeatInterval = 35;
  };

  programs.hyprland = {
    enable = true;
    package = pkgs-unstable.hyprland;
    xwayland.enable = true;
  };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  services.displayManager.autoLogin = {
    enable = true;
    user = "larke";
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  ###################
  ### SOUND       ###
  ###################

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  ###################
  ### BLUETOOTH   ###
  ###################

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  ###################
  ### USERS       ###
  ###################

  users.users.larke = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    packages = with pkgs; [
      tree
    ];
  };

  security.pam.services.hyprlock = {
      enableGnomeKeyring = true;
    };

  programs.fish.enable = true;
  users.users.larke.shell = pkgs.fish;



  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  ###################
  ### PROGRAMS    ###
  ###################

  nixpkgs.config.allowUnfree = true;

  environment.variables = {
    SUDO_EDITOR = "nvim";
    VISUAL = "nvim";
    EDITOR = "nvim";
  };


  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

  services.flatpak.enable = true;
  services.openssh.enable = true;


  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
    config.hyprland = {
      default = [ "hyprland" "gtk" ];
    };
  };

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
  security.pam.services.sddm-autologin.enableGnomeKeyring = true;
  services.gvfs.enable = true;

  services.tailscale.enable = true;
  services.udisks2.enable = true;

  

  # programs.spicetify = {
  #   enable = true;
  #   theme = inputs.spicetify-nix.legacyPackages.${pkgs.system}.themes.catppuccin;
  #   colorScheme = "mocha";
  #   spotifyPackage = pkgs.spotify;
  # };

  ###################
  ### GAMING      ###
  ###################


  # Proton-GE support
  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "~/.steam/root/compatibilitytools.d";
  };



  ###################
  ### PACKAGES    ###
  ###################

  environment.systemPackages = (with pkgs; [
    # Core
    neovim
    wget
    git
    kitty
    rofi
    libnotify
    jq
    tpm2-tools
    gcc
    adw-gtk3
    sage

    # Shell
    starship

    # Wayland / Desktop
    quickshell
    matugen
    gnome-keyring
    polkit_gnome
    wl-clipboard
    cliphist
    playerctl
    brightnessctl
    swappy
    grim
    slurp
    nautilus
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    wayfreeze
    pwvucontrol

    # Theming
    bibata-cursors
    papirus-icon-theme
    qt6Packages.qt6ct
    libsForQt5.qt5ct
    kdePackages.qtstyleplugin-kvantum

    # Media
    haruna
    mpv
    kdePackages.gwenview

    # Fetch
    fastfetch
    hyfetch

    # File management
    yazi
    fzf
    ripgrep
    zoxide

    # Gaming
    gamescope
    mangohud
    wineWow64Packages.staging
    winetricks
    lutris
    obs-studio
    gamemode

    # Bluetooth
    bluez-tools
    bluetuith

    # Virtualization
    virt-manager
    qemu

    # System utils
    btop
    ncdu
    fd
    imagemagick
    yt-dlp
    protonvpn-gui
    wireguard-tools

    # Other
    claude-code
  ]) ++ [
    inputs.helium.packages.${pkgs.system}.default
    inputs.zen-browser.packages.${pkgs.system}.default
    pkgs-unstable.awww
    pkgs-unstable.hyprlock
    pkgs-unstable.hypridle
  ];

  ###################
  ### FONTS       ###
  ###################

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts-cjk-sans
  ];

  ###################
  ### NIX         ###
  ###################
  
 
  system.activationScripts.flatpakSetup = ''
    ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  '';

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [ 
      "https://nix-cachyos-kernel.cachix.org" 
    ];
    trusted-public-keys = [
      "nix-cachyos-kernel.cachix.org-1:jRxrBiKdCMFhkOBvNgp9bBF+jBqhUVSHcJMuNkMgwu0="
    ];
  };


  nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
  };

  nix.optimise = {
      automatic = true;
      dates = [ "weekly" ];
  };



  system.stateVersion = "25.11";
}
