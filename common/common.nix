{
  config,
  lib,
  pkgs,
  ...
}: let
  sources = import ../npins;
  nixpkgs-unstable = import sources.nixpkgs-unstable {};
  firefoxWithEnv = pkgs.symlinkJoin {
    name = "firefox";
    paths = [pkgs.firefox];
    buildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/firefox \
        --set MOZ_USE_XINPUT2 1
    '';
  };
in {
  nixpkgs.overlays = [
    # not compatible with latest c3
    (import ./overlays/c3c.nix)
  ];
  imports = [
    ./tuigreet.nix
    ../i3/wm.nix
  ];
  services.usbmuxd.enable = true;
  environment.variables = {
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    PREFERRED_WM = "${config.host-info.preferred_wm}";
    OLLAMA_API_BASE = "http://100.112.153.1:11434";
    AIDER_MODEL = "ollama/qwen3:30b-a3b";
  };
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  networking.networkmanager.unmanaged = ["interface-name:ve-*"];
  networking.networkmanager.plugins = with pkgs; [
    networkmanager-openvpn
  ];
  networking.extraHosts = ''
    127.0.0.1 api.frisbo.internal
    127.0.0.1 superadmin.frisbo.internal
    127.0.0.1 api-merchant.frisbo.internal
    127.0.0.1 merchant.frisbo.internal
    127.0.0.1 api-admin.frisbo.internal
    127.0.0.1 admin.frisbo.internal
    127.0.0.1 api-fc.frisbo.internal
    127.0.0.1 task.frisbo.internal
    127.0.0.1 status.frisbo.internal
    127.0.0.1 beta.frisbo.internal
    127.0.0.1 dashboard.frisbo.internal
    127.0.0.1 rmq.frisbo.internal
    100.127.121.86 ai.me
    100.127.121.86 registry.stoica-marcu.ro
    127.0.0.1 auth.ocrasig.local
    127.0.0.1 app.ocrasig.local
    127.0.0.1 traefik.ocrasig.local
  '';
  # Set your time zone.
  time.timeZone = "Europe/Bucharest";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.sandbox = true;
  nix.settings.trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
    "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
  ];
  nix.settings.substituters = [
    "https://nix-community.cachix.org"
    "https://cache.flox.dev"
    "https://cuda-maintainers.cachix.org"
  ];
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  services.tailscale.enable = true;

  # Configure keymap in X11
  # services.xserver.layout = "us,ro";
  # services.xserver.xkbVariant = ",std";
  # services.xserver.xkbOptions = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.fwupd.enable = true;
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = false;
    };
    docker = {
      package = nixpkgs-unstable.docker;
      enable = true;
      enableOnBoot = false;
      daemon.settings = {
        insecure-registries = ["registry.stoica-marcu.ro"];
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

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.flow = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager" "video" "docker" "incus-admin" "libvirtd" "kvm" "libvirt"]; # Enable 'sudo' for the user.
  };
  home-manager.extraSpecialArgs = {
    inherit (config) host-info;
    inherit (config) home-manager;
    inherit nixpkgs-unstable;
  };
  home-manager.users.flow = import ./flow.nix;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs;
    [
      # niv for dependency management
      teams-for-linux
      # nodejs
      nodejs
      corepack
      # zot
      (nixpkgs-unstable.callPackage ./packages/sqlit.nix {} )
      npins
      # networking
      dig
      bc
      # k8s
      kind
      kubernetes-helm
      # others
      natscli
      clang-tools
      tmux
      lsof
      pstree
      util-linux
      python3
      python3Packages.pip
      vim
      libva-utils
      wget
      remmina
      marktext
      dvdplusrwtools
      cdrtools
      openjdk17
      # browsers
      firefoxWithEnv
      # chromium
      # utils
      tree
      powertop
      # stremio
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
      nixos-container
    ]
    ++ (
      if (config.host-info.gpu == "nvidia")
      then [cudatoolkit nvtopPackages.nvidia colmapWithCuda]
      else []
    )
    ++ (
      if (config.host-info.preferred_wm == "i3")
      then [sx]
      else []
    );

  # enable CUDA when on nvidia hardware
  nixpkgs.config.cudaSupport = config.host-info.gpu == "nvidia";

  programs.extra-container.enable = true;
  programs.nix-ld.enable = true;
  programs.mosh.enable = true;
  programs.seahorse.enable = true;
  programs.gamemode.enable = true;
  programs.steam = {
    enable = true;
    protontricks.enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };
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
      "teams-for-linux"
      "stremio-shell"
      "stremio-server"
      "android-studio"
      "android-studio-stable"
      # Add additional package names here
      "corefonts"
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
      extraPkgs = pkgs:
        with pkgs; [
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
    nerd-fonts.fira-code
    nerd-fonts.inconsolata
    nerd-fonts.caskaydia-cove
    nerd-fonts.droid-sans-mono
    nerd-fonts.iosevka-term
    nerd-fonts.meslo-lg
    corefonts
    cantarell-fonts
    ubuntu-sans
    twitter-color-emoji
    source-code-pro
    gentium
    jigmo
  ];
  fonts.fontconfig.defaultFonts = {
    serif = ["Gentium Plus"];
    sansSerif = ["Droid Sans Mono"];
    monospace = ["Inconsolata Nerd Font Mono"];
    emoji = ["Twitter Color Emoji"];
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
  programs.git = {
    enable = true;
    lfs.enable = true;
  };
  services.flatpak.enable = true;
  services.ipp-usb.enable = true;

  services.printing.enable = true;
  services.printing.drivers = [
    pkgs.gutenprint
    pkgs.hplip
    pkgs.brlaser
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

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;
  boot.enableContainers = true;
}
