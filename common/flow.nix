{
  pkgs,
  lib,
  host-info,
  ...
}: let
  thunarWithPlugins = pkgs.xfce.thunar.override {
    thunarPlugins = [pkgs.xfce.thunar-volman pkgs.xfce.thunar-archive-plugin];
  };

  unstable-pkgs = import <nixos-unstable> {config.allowUnfree = true;};
  mkNeovimWrapper = name: ''
    #!/usr/bin/env bash
    source "$HOME/.config/neovim-profile-env.sh"
    exec "$PROFILE/bin/${name}" "$@"
  '';
in {
  imports = [
    ../sway/sway.nix
    ../i3/i3.nix
    ../i3/picom.nix
    ../i3/polybar.nix
    ../i3/rofi.nix
    ../special/cybersecurity.nix
  ];
  home.stateVersion = "25.11";
  fonts.fontconfig.enable = true;

  xdg = {
    enable = true;
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
      neofetch
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
      wdisplays
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
      then [unstable-pkgs.ollama-cuda]
      else []
    );

  programs.neovim = {
    enable = true;
    package = unstable-pkgs.neovim-unwrapped;
    vimAlias = true;
    withNodeJs = true;
  };

  home.file.".config/opencode/dev/bin/opencoder-dev".source = ./dev-coder.sh;
  home.file."./.config/nvim/" = {
    source = ./nvim;
    recursive = true;
  };

  # neovim
  home.file."./.config/nvim/lua/flow/init.lua".text = ''
    require("flow.set")
    require("flow.remap")
  '';
  home.activation.commonDirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p "$HOME/.npm-global"
    mkdir -p "$HOME/.local/bin"
  '';
  home.activation.neovimProfileStateDirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
    STATE="$HOME/.local/state/neovim-profile"

    mkdir -p \
      "$STATE/cargo" \
      "$STATE/rustup" \
      "$STATE/npm" \
      "$STATE/npm/lib/node_modules" \
      "$STATE/composer" \
      "$STATE/nuget"
  '';
  home.file.".config/neovim-profile-env.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      PROFILE="$HOME/.nix-profile-neovim"
      STATE="$HOME/.local/state/neovim-profile"

      export CARGO_HOME="$STATE/cargo"
      export RUSTUP_HOME="$STATE/rustup"

      export NPM_CONFIG_PREFIX="$STATE/npm"
      export NODE_PATH="$STATE/npm/lib/node_modules"

      export COMPOSER_HOME="$STATE/composer"
      export NUGET_PACKAGES="$STATE/nuget"

      export PATH="$PROFILE/bin:$PATH"
    '';
  };
  home.file.".config/neovim-wrapper/bin/cargo" = {
    text = mkNeovimWrapper "cargo";
    executable = true;
  };
  home.file.".config/neovim-wrapper/bin/composer" = {
    text = mkNeovimWrapper "composer";
    executable = true;
  };
  home.file.".config/neovim-wrapper/bin/nuget" = {
    text = mkNeovimWrapper "nuget";
    executable = true;
  };
  home.file.".config/neovim-wrapper/bin/npm" = {
    text = mkNeovimWrapper "npm";
    executable = true;
  };

  # we hardcode a symlink here so that we can refer to it in our lazy config
   home.file.".config/foot/foot.ini".source = ./foot.ini;
   home.file.".config/alacritty/alacritty.toml".source = ./alacritty.toml;
   home.file.".bashrc".source = ./bashrc;
   home.file."startWm.sh".source = ./startWm.sh;
   home.file.".config/rofi/edit.sh".source = ../i3/rofi/edit.sh;
 }
