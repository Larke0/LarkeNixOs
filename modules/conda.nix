# /etc/nixos/modules/conda.nix
{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.conda
  ];

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    zlib
    stdenv.cc.cc.lib
    libGL
    glib
  ];
}
