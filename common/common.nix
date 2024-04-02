{ config, pkgs, lib, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_latest;
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  networking.extraHosts =
  ''
    127.0.0.1 api.frisbo.internal
    127.0.0.1 superadmin.frisbo.internal
    127.0.0.1 beta.frisbo.internal
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
    };
  };

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;
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
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  hardware.keyboard.qmk.enable = true;


  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.flow = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "docker" ]; # Enable ‘sudo’ for the user.
  };
  home-manager.users.flow = import ./flow.nix;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    util-linux
    python3
    vim
    libva-utils
    wget
    firefox
    tree
    powertop
    vlc
    gcr
    xdg-utils
    coreutils
    moreutils
    e2fsprogs
    unzip
  ];
  programs.nix-ld.enable = true;
  programs.seahorse.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };
  programs.light.enable = true;
  programs.dconf.enable = true;
  programs.xfconf.enable = true;

  security.polkit.enable = true;
  security.pam.services.swaylock = {
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
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" "IosevkaTerm" "Meslo" ]; })
    corefonts
    cantarell-fonts
    twitter-color-emoji
    source-code-pro
    gentium
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
  services.printing.enable = true;
  services.printing.drivers = [ 
    pkgs.hplip 
    pkgs.samsung-unified-linux-driver
    pkgs.splix 
  ];

  # Enable the OpenSSH daemon.
  services.avahi = {
    enable = true;
    nssmdns = true;
    openFirewall = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd sway";
        user = "greeter";
      };
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;
}
