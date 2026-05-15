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
        renice = -10;
        softrealtime = "auto";
        inhibit_screensaver = 1;
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
      };
      cpu = {
        park_cores = "no";
        pin_cores = "no";
      };
    };
  };


  # Power profiles daemon — switches to performance during gaming
  services.power-profiles-daemon.enable = true;

  # KERNEL BOOT PARAMETERS
  boot.kernelParams = [
    "amd-pstate=active"
    "amdgpu.aspm=0"
    "nmi_watchdog=0"
    "nowatchdog"
    "transparent_hugepage=never"
    "audit=0"
    "pcie_aspm=off"
    "ignore_rlimit_data"
    "split_lock_detect=off"
    "split_lock_mitigate=0"
    "preempt=full"
    "libahci.ignore_sss=1"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "transparent_hugepage_tmpfs=never"
    "amdgpu.dcdebugmask=0x4"
  ];

  # TCP BBR congestion control requires the kernel module to be loaded first
  boot.kernelModules = [ "tcp_bbr" ];

  # SYSCTL PARAMETERS
  boot.kernel.sysctl = {
    "vm.swappiness" = 1;
    "net.core.busy_read" = 50;
    "vm.max_map_count" = 2147483642; # Crucial for some Windows games via Proton/Wine
    "vm.vfs_cache_pressure" = 50;
    "vm.dirty_ratio" = 80;
    "vm.dirty_background_bytes" = 67108864;
    "net.ipv4.tcp_mtu_probing" = 1;
    "vm.page_lock_unfairness" = 3;
    "kernel.printk_devkmsg" = "off";
    "vm.stat_interval" = 10;
    "vm.zone_reclaim_mode" = 0;
    "vm.compaction_proactiveness" = 0;
    "vm.overcommit_memory" = 1;
    "kernel.threads-max" = 1073741823;
    "kernel.split_lock_mitigate" = 0;
    "vm.dirty_writeback_centisecs" = 60;
    
    # Network Tweaks
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
    "net.core.rmem_default" = 8388608;
    "net.core.wmem_default" = 8388608;
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.netdev_max_backlog" = 16384;

    # Security & Kernel Behavior
    "vm.unprivileged_userfaultfd" = 1;
    "kernel.nmi_watchdog" = 0;
    "kernel.unprivileged_userns_clone" = 1;
    "kernel.printk" = "3 3 2 3"; # Keep as a string since it has spaces
    "kernel.kptr_restrict" = 1;
  };



  # Use LAVD scheduler
  services.scx = {
    enable = true;
    scheduler = "scx_lavd";
  };

  # Virtualization 
  virtualisation.libvirtd.enable = true;

  # Desktop-only packages
  environment.systemPackages = with pkgs; [
    (llama-cpp.override { vulkanSupport = true; })
    wtype
  ];

  programs.quartus.enable = true;

  services.ollama = {
    enable = true;
    # Tell the service to use the specific Vulkan-enabled build
    package = pkgs-unstable.ollama-vulkan;
  };

   # Ensure the ollama user can access the hardware
  users.groups.render.members = [ "ollama" ];
  users.groups.video.members = [ "ollama" ];

  services.open-webui = {
    enable = true;
    port = 8080; 
    environment = {
      OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
      
      # Tell Open WebUI to allow web search
      ENABLE_RAG_WEB_SEARCH = "True";
      RAG_WEB_SEARCH_ENGINE = "searxng";
      RAG_WEB_SEARCH_RESULT_COUNT = "3";
      SEARXNG_QUERY_URL = "http://127.0.0.1:8081/search?q=<query>";
    };
  };

  services.searx = {
    enable = true;
    settings = {
      server = {
        port = 8081;
        bind_address = "127.0.0.1";
        secret_key = "b013d6db3368b9c091fd2c8c923d400a63db4236834c16d2ee7eb9101043c0bc";
      };
      search = {
        # JSON format is required for the LLM to parse the results
        formats = [ "html" "json" ]; 
      };
    };
  };
}
