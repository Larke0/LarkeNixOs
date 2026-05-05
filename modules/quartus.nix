{ pkgs, ... }:
let
  quartus-env = pkgs.writeShellScriptBin "quartus-env" ''
    exec ${pkgs.steam-run}/bin/steam-run bash "$@"
  '';
in
{
  environment.systemPackages = [ quartus-env ];
}
