# /etc/nixos/modules/conda.nix
{ pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.buildFHSEnv {
      name = "conda-env";
      targetPkgs = pkgs: with pkgs; [
        conda
        zlib
        glib
        libGL
        stdenv.cc.cc.lib
        coreutils
        bashInteractive
        git
        curl
        which
      ];
      profile = ''
        eval "$(conda shell.bash hook)"
        export CONDA_ENVS_PATH="$HOME/.conda/envs"
        export CONDA_PKGS_DIRS="$HOME/.conda/pkgs"
      '';
      runScript = "bash";
    })
  ];

  # While we're at it, enable nix-ld as a safety net
  # for other dynamically-linked binaries conda pulls in
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    zlib
    stdenv.cc.cc.lib
    libGL
    glib
  ];
}
