{ pkgs, lib, config, ... }:
let
  cfg = config.programs.quartus;
  libs = with pkgs.pkgsi686Linux; [
    libpng12
    freetype
    fontconfig
    xorg.libXrender
    xorg.libXi
    xorg.libXtst
    xorg.libXext
    xorg.libX11
    xorg.libSM
    xorg.libICE
    xorg.libXScrnSaver
    alsa-lib
    libjpeg_original
    unixODBC
    tbb
    #qt4
  ];
  libPath = pkgs.lib.makeLibraryPath libs;

  quartus-env = pkgs.writeShellScriptBin "quartus-env" ''
    exec ${pkgs.steam-run}/bin/steam-run env LD_LIBRARY_PATH="${libPath}:''${LD_LIBRARY_PATH:-}" bash "$@"
  '';
  quartus = pkgs.writeShellScriptBin "quartus" ''
    exec ${pkgs.steam-run}/bin/steam-run env LD_LIBRARY_PATH="${libPath}:''${LD_LIBRARY_PATH:-}" ~/.altera/13.0sp1/quartus/bin/quartus "$@"
  '';
  quartus-desktop = pkgs.makeDesktopItem {
    name = "quartus";
    desktopName = "Quartus II";
    exec = "${quartus}/bin/quartus";
    icon = "/home/larke/.altera/13.0sp1/quartus/adm/quartusii.png";
    comment = "Quartus II Web Edition 13.0";
    categories = [ "Development" "Electronics" ];
  };
in
{
options.programs.quartus.enable = lib.mkEnableOption "Quartus II";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ quartus-env quartus quartus-desktop ];
  };
}
