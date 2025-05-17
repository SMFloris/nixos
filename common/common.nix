{ config, pkgs, lib, fetchFromGitHub, fetchFromGitLab, ... }:

let
  unstable = import <nixos-unstable> {config.allowUnfree = true;};
in {
  nixpkgs.overlays = [ (import ./overlays/c3-lsp.nix) (import ./overlays/c3c.nix) ];
  imports = [
    ./tuigreet.nix
    ../i3/wm.nix
  ];
  services.usbmuxd.enable = true;
  environment.variables = {
    PREFERRED_WM = "${config.host-info.preferred_wm}";
    OLLAMA_API_BASE = "http://100.112.153.1:11434";
    AIDER_MODEL = "ollama/qwen3:30b-a3b";
  };
  nix.useSandbox = true;
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  networking.extraHosts =
    ''
      127.0.0.1 api.frisbo.internal
      127.0.0.1 superadmin.frisbo.internal
      127.0.0.1 status.frisbo.internal
      127.0.0.1 beta.frisbo.internal
      127.0.0.1 dashboard.frisbo.internal
      127.0.0.1 rmq.frisbo.internal
      100.127.121.86 ai.me
      100.126.121.86 registry.stoica-marcu.ro
    '';
  # Set your time zone.
  time.timeZone = "Europe/Bucharest";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  services.tailscale.enable = true;

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;
  services.fwupd.enable = true;
  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = false;
      daemon.settings = {
        insecure-registries = [ "registry.stoica-marcu.ro" ];
      };
    };
    vswitch = {
      enable = true;
      resetOnStart = true;
    };

    oci-containers = {
      backend = "docker";
      containers = {
        jupyter = {
          image = "quay.io/jupyter/base-notebook";
          cmd = ["start-notebook.py" "--NotebookApp.token='mumstheword'"];
          volumes = [
            "jupyter-data:/home/jovyan/work"
          ];
          ports = [
            "8889:8888"
          ];
        };
      };
    };
  };

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.rtkit.enable = true;
  services.udisks2.enable = true;
  services.blueman.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;
  };

  services.tumbler.enable = true;
  services.gvfs = {
    enable = true;
    package = lib.mkForce pkgs.gnome.gvfs;
  };
  hardware.keyboard.qmk.enable = true;


  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.flow = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "docker" "incus-admin" "libvirtd" "kvm" "libvirt" ]; # Enable ‘sudo’ for the user.
  };
  home-manager.users.flow = (import ./flow.nix {inherit config pkgs lib;});

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # zot
    (pkgs.callPackage (import ./packages/zil.nix) {})
    # networking
    dig
    bc
    # k8s
    kind
    kubernetes-helm
    # others
    tmux
    lsof
    pstree
    util-linux
    python3
    python3Packages.pip
    vim
    libva-utils
    wget
    # browsers
    firefox
    chromium
    # utils
    tree
    powertop
    vlc
    gcr
    xdg-utils
    coreutils
    moreutils
    e2fsprogs
    unzip
    virt-viewer
    quickemu
    cifs-utils
    libsecret
    appimage-run
    seabird
    # ai
    unstable.aider-chat
  ] ++ (if (config.host-info.gpu == "nvidia") then  [cudatoolkit nvtopPackages.nvidia] else [])
    ++ (if (config.host-info.preferred_wm == "i3") then [sx] else []);

  # enable CUDA when on nvidia hardware
  nixpkgs.config.cudaSupport = config.host-info.gpu == "nvidia";

  programs.nix-ld.enable = true;
  programs.seahorse.enable = true;
  programs.gamemode.enable = true;
  programs.steam = {
    enable = true;
    protontricks.enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };
  programs.light.enable = true;
  programs.dconf.enable = true;
  programs.xfconf.enable = true;
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  security.polkit.enable = true;
  security.pam.services.swaylock = lib.mkIf (config.host-info.preferred_wm == "sway") {
    text = "auth include login";
  };
  xdg = {
    mime = {
      enable = true;
      addedAssociations = {
        "application/pdf" = "org.gnome.Evince.desktop";
        "image/png" = "org.xfce.ristretto.desktop";
        "image/jpg" = "org.xfce.ristretto.desktop";
      };
      defaultApplications = {
        "application/pdf" = "org.gnome.Evince.desktop";
        "image/png" = "org.xfce.ristretto.desktop";
        "image/jpg" = "org.xfce.ristretto.desktop";
      };
    };
    portal = {
      enable = true;
      config.common.default = "*";
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
      wlr = {
        enable = true;
      };
    };
  };
  # steam
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      # Add additional package names here
      "corefonts"
      "samsung-UnifiedLinuxDriver"
      "steam"
      "steam-original"
      "steam-run"
      "steam-unwrapped"
      "terraform"
      "slack"
      "mongodb-compass"
      "spotify"
      "blender"
      "phpstorm"
      # nvidia proprietary drivers + cuda
      "nvidia-persistenced"
      "nvidia-x11"
      "nvidia-settings"
      "cuda_sanitizer_api"
      "cuda_profiler_api"
      "cuda_nvtx"
      "cudnn"
      "cuda_nvrtc"
      "cuda_nvml_dev"
      "cuda_cuxxfilt"
      "cuda_cupti"
      "cuda_nvprune"
      "cuda_nvdisasm"
      "cuda_gdb"
      "cuda_cuobjdump"
      "cuda_nvcc"
      "cuda-merged"
      "cuda_cccl"
      "cuda_cudart"
      "libnvjitlink"
      "libcurand"
      "libnpp"
      "libcufft"
      "libcublas"
      "libcusparse"
      "libcusolver"
  ];
  nixpkgs.config.packageOverrides = pkgs: {
    steam = pkgs.steam.override {
      extraPkgs = pkgs: with pkgs; [
        xorg.libXcursor
        xorg.libXi
        xorg.libXinerama
        xorg.libXScrnSaver
        libpng
        libpulseaudio
        libvorbis
        stdenv.cc.cc.lib
        libkrb5
        keyutils
      ];
    };
  };
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "CascadiaCode" "FiraCode" "DroidSansMono" "IosevkaTerm" "Meslo" ]; })
    corefonts
    cantarell-fonts
    twitter-color-emoji
    source-code-pro
    gentium
    jigmo
  ];
  fonts.fontconfig.defaultFonts = {
    serif = [ "Gentium Plus" ];
    sansSerif = [ "Cantarell" ];
    monospace = [ "Source Code Pro" ];
    emoji = [ "Twitter Color Emoji" ];
  };
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  hardware.sane.enable = true;
  services.ipp-usb.enable = true;
  services.printing.enable = true;
  services.printing.drivers = [
    pkgs.gutenprint
    pkgs.hplip
    pkgs.brlaser
    pkgs.samsung-unified-linux-driver
    pkgs.splix
  ];

  # Enable the OpenSSH daemon.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
    settings.X11Forwarding = true;
  };

  # ollama
  systemd.user.services.ollama = lib.mkIf (config.host-info.ai_enabled == true) {
    description = "ollama";
    serviceConfig = {
        Type = "simple";
        ExecStart = if (config.host-info.gpu == "nvidia") then "${unstable.ollama-cuda}/bin/ollama serve" else "${unstable.ollama}/bin/ollama serve";
        Environment = [
            "OLLAMA_HOST=0.0.0.0:11434"
            "OLLAMA_CONTEXT_LENGTH=40960"
        ];
        Restart = "on-failure";
        RestartSec = 10;
        TimeoutStopSec = 20;
      };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;
}
