#VERSION 9 

{config, pkgs, inputs, ... }:
{
	home.username = "larke";
	home.homeDirectory = "/home/larke";
	home.stateVersion = "25.11";
  programs.git = {
    enable = true;
    settings.user.name = "Larke0";
    settings.user.email = "larke850@gmail.com";
  };
	programs.fish = {
		enable = true;
    interactiveShellInit = ''
        starship init fish | source
        function starship_transient_prompt_func
            starship module character
        end
        enable_transience
        #hyfetch -b fastfetch
        set -g fish_greeting
    '';
    functions = {
       calc = "sage -c $argv";
    }; 
		shellAliases = {
			btw = "echo I use nixos, btw";
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#(hostname)";
      set-wallpaper = "~/.config/quickshell/scripts/set-wallpaper.sh";
      sync-dots = "cd ~/Larke-shell && ${pkgs.git}/bin/git fetch --all && ${pkgs.git}/bin/git reset --hard origin/main && find ~/Larke-shell -name '*.sh' -exec sed -i 's|#!/bin/bash|#!/usr/bin/env bash|g' {} \\; && find ~/Larke-shell -name '*.sh' -exec chmod +x {} \\;";
      push-dots = "cd ~/Larke-shell && git add -A && git commit -m 'update dots' && git push";
      zen-browser = "zen";
      ngit = "sudo GIT_SSH_COMMAND='ssh -i /home/larke/.ssh/id_ed25519' git -C /etc/nixos";
		};
	};
	
	
	home.activation.cloneDotfiles = config.lib.dag.entryAfter [ "writeBoundary" ] ''
		if [ ! -d "$HOME/Larke-shell" ]; then
			${pkgs.git}/bin/git clone https://github.com/Larke0/Larke-shell "$HOME/Larke-shell"
		else
			cd "$HOME/Larke-shell" && ${pkgs.git}/bin/git fetch --all && ${pkgs.git}/bin/git reset --hard origin/main || echo "GIT PULL FAILED" 
		fi
		

		find "$HOME/Larke-shell/" -name "*.sh" -exec sed -i 's|#!/bin/bash|#!/usr/bin/env bash|g' {} \;

    find "$HOME/Larke-shell/" -name "*.sh" -exec chmod +x {} \; 
    
    mkdir -p "$HOME/.config/hypr"
    mkdir -p "$HOME/.config/hypr/custom"
    mkdir -p "$HOME/.config/hypr/assets"

    mkdir -p "$HOME/.config/gtk-3.0"
    mkdir -p "$HOME/.config/gtk-4.0"


		# Sync configs
    # For dirs that are fully managed, symlink the whole folder
    for dir in quickshell nvim matugen kitty fastfetch rofi qt6ct Kvantum; do
      rm -rf "$HOME/.config/$dir"
      ln -sfn "$HOME/Larke-shell/.config/$dir" "$HOME/.config/$dir"
    done

    # For hypr, symlink subfolders individually (skip custom/)
    for dir in hyprland scripts GameWorkspace; do
      rm -rf "$HOME/.config/hypr/$dir"
      ln -sfn "$HOME/Larke-shell/.config/hypr/$dir" "$HOME/.config/hypr/$dir"
    done

    # Symlink individual hypr root files
    for file in hyprland.conf hypridle.conf hyprlock.conf xdph.conf; do
      ln -sfn "$HOME/Larke-shell/.config/hypr/$file" "$HOME/.config/hypr/$file"
    done

    # Link starship.toml
    ln -sfn "$HOME/Larke-shell/.config/starship.toml" "$HOME/.config/starship.toml"

    # For gtk, just symlink the settings files :3
    mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
    ln -sfn "$HOME/Larke-shell/.config/gtk-3.0/settings.ini" "$HOME/.config/gtk-3.0/settings.ini"
    ln -sfn "$HOME/Larke-shell/.config/gtk-4.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"

    # Also link the hyprland.conf.example:
    ln -sfn "$HOME/Larke-shell/.config/hypr/custom/hyprland.conf.example" "$HOME/.config/hypr/custom/hyprland.conf.example"

    touch ~/.config/hypr/hyprland/theme.conf ~/.config/hypr/custom/hyprland.conf

    
    # GTK settings
    export GSETTINGS_SCHEMA_DIR="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas"
    ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
    ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
    ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic'
    ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface cursor-size 24
	'';


  
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = "org.gnome.Nautilus.desktop";
      "text/plain" = "nvim-kitty.desktop";
      "x-scheme-handler/http" = "helium.desktop";
      "x-scheme-handler/https" = "helium.desktop";
      "x-scheme-handler/about" = "helium.desktop";
      "x-scheme-handler/unknown" = "helium.desktop";
      "application/zip" = "org.gnome.Nautilus.desktop";
    };
  };

  xdg.desktopEntries.nvim-kitty = {
    name = "Neovim";
    exec = "kitty nvim %F";
    terminal = false;
    mimeType = [ "text/plain" ];
  };

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = "${config.home.homeDirectory}/Desktop";
    documents = "${config.home.homeDirectory}/Documents";
    download = "${config.home.homeDirectory}/Downloads";
    music = "${config.home.homeDirectory}/Music";
    pictures = "${config.home.homeDirectory}/Pictures";
    videos = "${config.home.homeDirectory}/Videos";
    templates = "${config.home.homeDirectory}/Templates";
    publicShare = "${config.home.homeDirectory}/Public";
  };


  xdg.desktopEntries.ytmusic = {
    name = "Youtube Music";
    exec = "helium --app=https://music.youtube.com/";
    terminal = false;
    icon = "youtube-music";
  };

  services.flatpak = {
    enable = true;
    remotes = [
        { name = "flathub"; location = "https://flathub.org/repo/flathub.flatpakrepo"; }
    ];
    packages = [
        "io.github.kolunmi.Bazaar"
    ];
};


}
