{ config, lib, pkgs, pkgs-unstable, inputs, ... }:

{
  networking.hostName = "suika";


  # Nvidia + Intel hybrid GPU
  services.xserver.videoDrivers = [ "nvidia" ];



  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";    # verify with lspci on the laptop
      nvidiaBusId = "PCI:1:0:0";   # verify with lspci on the laptop
    };
  };

  boot.extraModprobeConfig = ''
    options nvidia NVreg_DynamicPowerManagement=0x02
  '';

  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
    intel-vaapi-driver
    libva-vdpau-driver
    libvdpau-va-gl
  ];

  # Laptop power management
  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "powersave";
        turbo = "never";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
  };

  services.thermald.enable = true;
  services.upower.enable = true;

   # TLP for deep hardware-level power management
  services.tlp = {
    enable = true;
    settings = {
      # NO CPU_SCALING_GOVERNOR lines — auto-cpufreq handles that
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

      PLATFORM_PROFILE_ON_BAT = "low-power";
      PLATFORM_PROFILE_ON_AC = "performance";

      RUNTIME_PM_ON_BAT = "auto";
      RUNTIME_PM_ON_AC = "on";
      USB_AUTOSUSPEND = 1;

      WIFI_PWR_ON_BAT = "on";
      WIFI_PWR_ON_AC = "off";

      SATA_LINKPWR_ON_BAT = "med_power_with_dipm";
      SATA_LINKPWR_ON_AC = "max_performance";

      SOUND_POWER_SAVE_ON_BAT = 1;
      SOUND_POWER_SAVE_ON_AC = 0;
    };
  };


  # Nvidia power management (turn off GPU when not in use)
  hardware.nvidia.powerManagement.finegrained = true;

   # Swap
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  boot.kernel.sysctl = {
    "vm.swappiness" = 60;
  };

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    LIBVA_DRIVER_NAME = "iHD";
    #LIBVA_DRIVER_NAME = "nvidia";
    #__GLX_VENDOR_LIBRARY_NAME = "nvidia";
    #GBM_BACKEND = "nvidia_drm";
  };

  boot.kernelParams = [
    "i915.enable_psr=1"       # Intel panel self-refresh
    "i915.enable_fbc=1"       # framebuffer compression
    "iwlwifi.power_save=1"    # Intel wifi power save

    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
  ];

  # Touchpad
  services.libinput = {
    enable = true;
    touchpad = {
      tapping = true;
      naturalScrolling = true;
      disableWhileTyping = false;
    };
  };

  environment.systemPackages = (with pkgs; [
    powertop
  ]); 


  programs.quartus.enable = true;
}
