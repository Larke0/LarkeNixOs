{
  description = "Hydra Launcher";

  inputs.nixpkgs.url = "nixpkgs/nixos-25.11";

  outputs = { self, nixpkgs }: {
    nixosModules.hydra-launcher = { pkgs, lib, config, ... }: {  
      options.programs.hydra-launcher.enable = lib.mkEnableOption "Hydra Launcher";

      config = lib.mkIf config.programs.hydra-launcher.enable {
        environment.systemPackages = [
          (pkgs.appimageTools.wrapType2 {
            pname = "hydra-launcher";
            version = "3.9.7";
            src = pkgs.fetchurl {
              url = "https://github.com/hydralauncher/hydra/releases/download/v3.9.7/hydralauncher-3.9.7.AppImage";
              hash = "sha256-VQYgmsWS/5naSlcbTeIUkFb79lwlVO1HZbf23TDsHH0=";
            };
            extraInstallCommands = ''
              mkdir -p $out/share/applications
              mkdir -p $out/share/icons/hicolor/256x256/apps
              cp ${pkgs.fetchurl {
                url = "https://raw.githubusercontent.com/hydralauncher/hydra/main/resources/icon.png";
                hash = "sha256-Lw4qobE9IlGoKm0gZ11SRFqY8eZbEkYBC9f9FrfzTuw=";
              }} $out/share/icons/hicolor/256x256/apps/hydra-launcher.png
              cat > $out/share/applications/hydra-launcher.desktop <<EOF
              [Desktop Entry]
              Name=Hydra Launcher
              Exec=hydra-launcher
              Icon=hydra-launcher
              Type=Application
              Categories=Game;
              EOF
            '';
          })
        ];
      };
    };
  };
}
