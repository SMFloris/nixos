{
  pkgs,
  lib,
  host-info,
  nixpkgs-unstable,
  ...
}:

{
  imports = [
    ./wm/i3/i3.nix
    ./wm/sway/sway.nix
    ./wm/cosmic/cosmic.nix
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
      pkgs = pkgs.extend (final: prev: {
        c3-lsp = final.callPackage ./packages/c3-lsp.nix {
          c3c = nixpkgs-unstable.c3c;
        };
        phpantom = final.callPackage ./packages/phpantom-lsp.nix {};
      });
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
      # neovim
      ripgrep
      fd
      lua-language-server
      rust-analyzer-unwrapped
      lazygit
      black
      (writeShellScriptBin "wcodex" ''
        exec env CODEX_HOME=/home/flow/.codex-work codex "$@"
      '')
      # programming
      k9s
      go
      php
      phpPackages.composer
      tmux
      gcr
      cargo
      nixpkgs-unstable.c3c
      git
      gcc
      fzf
      nixpkgs-unstable.godot
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
      nixpkgs-unstable.yaak
      ipe
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
      gnome-disk-utility
      simple-scan
      networkmanagerapplet
      transmission_4-gtk
      hexchat
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

  home.file.".bashrc".source = ./bashrc;
}
