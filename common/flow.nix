{
  pkgs,
  lib,
  host-info,
  nixpkgs-unstable,
  ...
}: let
  thunarWithPlugins = pkgs.xfce.thunar.override {
    thunarPlugins = [pkgs.xfce.thunar-volman pkgs.xfce.thunar-archive-plugin];
  };
in {
  imports = [
    ../sway/sway.nix
    ../i3/i3.nix
    ../i3/picom.nix
    ../i3/polybar.nix
    ../i3/rofi.nix
    ../special/cybersecurity.nix
    ./neonix-hm-module.nix
  ];
  home.stateVersion = "25.11";
  fonts.fontconfig.enable = true;

  xdg = {
    enable = true;
  };

  programs.neonix = {
    enable = true;
    packageSets = {
      pkgs = pkgs;
      pkgs-unstable = nixpkgs-unstable;
    };
    nvimPackage = nixpkgs-unstable.neovim-unwrapped;
  };

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "teams-for-linux"
      "terraform"
      "mongodb-compass"
      "spotify"
    ];

  home.packages = with pkgs;
    [
      rofi
      # neovim
      ripgrep
      fd
      lua-language-server
      rust-analyzer-unwrapped
      lazygit
      black
      # programming
      k9s
      go
      php
      phpPackages.composer
      tmux
      gcr
      cargo
      foot
      git
      gcc
      fzf
      c3c
      c3-lsp
      godot_4
      # utils cli
      bc
      jq
      yq-go
      pciutils
      usbutils
      libmbim
      gnome-sound-recorder
      pavucontrol
      btop
      calcurse
      dbus
      fastfetch
      tigervnc
      easyocr
      # clouds
      terraform
      kubectl
      kustomize
      doctl
      mysql-workbench
      mongodb-compass
      appimage-run
      awscli2
      google-cloud-sdk-gce
      # utils gui
      bruno
      evince
      insomnia
      system-config-printer
      meld
      octave
      libreoffice
      # media
      blender
      gimp
      # sync
      maestral
      maestral-gui
      # fun
      gamescope
      spotify
      # keyboard
      ttyper
      wev
      vial
      qmk
      # extra
      file-roller
      thunarWithPlugins
      xfce.ristretto
      xfce.thunar-volman
      xfce.thunar-archive-plugin
      sway-contrib.grimshot
      gnome-clocks
      gnome-calculator
      gnome-disk-utility
      simple-scan
      networkmanagerapplet
      transmission_4-gtk
      hexchat
      gImageReader
    ]
    ++ (
      if (host-info.ai_enabled)
      then []
      else []
    )
    ++ (
      if (host-info.gpu == "nvidia")
      then []
      else []
    );
  home.activation.commonDirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p "$HOME/.npm-global"
    mkdir -p "$HOME/.local/bin"
  '';

  home.keyboard = {
    layout = "us,ro";
    options = ["grp:alt_shift_toggle"];
  };

  # we hardcode a symlink here so that we can refer to it in our lazy config
   home.file.".config/foot/foot.ini".source = ./foot.ini;
   home.file.".config/alacritty/alacritty.toml".source = ./alacritty.toml;
   home.file.".bashrc".source = ./bashrc;
   home.file."startWm.sh".source = ./startWm.sh;
   home.file.".config/rofi/edit.sh".source = ../i3/rofi/edit.sh;
 }
