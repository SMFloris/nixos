{ config, pkgs, lib, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_latest;
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  # Set your time zone.
  time.timeZone = "Europe/Bucharest";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
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
  virtualisation = {
    docker = {
      enable = true;
    };
  };

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
	  enable = true;
	  alsa.enable = true;
	  alsa.support32Bit = true;
	  pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;
  };

  services.tumbler.enable = true;

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
    xfce.ristretto
    vlc
  ];

  programs.light.enable = true;
  programs.dconf.enable = true;

  security.polkit.enable = true;
  security.pam.services.swaylock = {
    text = "auth include login";
  };
  xdg = {
      mime = {
	    enable = true;
      	addedAssociations = {
	        "application/pdf" = "firefox.desktop";
	        "image/png" = "org.xfce.ristretto.desktop";
	        "image/jpg" = "org.xfce.ristretto.desktop";
      };
      	defaultApplications = {
	        "application/pdf" = "firefox.desktop";
	        "image/png" = "org.xfce.ristretto.desktop";
	        "image/jpg" = "org.xfce.ristretto.desktop";
      };
    };
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
      wlr = {
      	enable = true;
      };
    };
  };
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      # Add additional package names here
      "corefonts"
  ];
  fonts.fonts = with pkgs; [
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

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;
}
