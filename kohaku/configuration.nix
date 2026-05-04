{ config, lib, pkgs, pkgs-unstable, inputs, ... }:

{
  networking.hostName = "kohaku";

  # AMD GPU if needed

  # Gaming optimizations
  programs.gamemode = {
    enable = true;
    enableRenice = true;
    settings = {
      general = {
        renice = 10;
        softrealtime = "auto";
        inhibit_screensaver = 1;
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
      };
      cpu = {
        park_cores = "no";
        pin_cores = "yes";
      };
    };
  };


  # Power profiles daemon — switches to performance during gaming
  services.power-profiles-daemon.enable = true;

  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.compaction_proactiveness" = 0;
  };

  # Virtualization 
  virtualisation.libvirtd.enable = true;

  # Desktop-only packages
  environment.systemPackages = with pkgs; [
  ];
}
