{ pkgs, lib, host-info, ... }:

let
  thunarWithPlugins = pkgs.xfce.thunar.override {
    thunarPlugins = [ pkgs.xfce.thunar-volman pkgs.xfce.thunar-archive-plugin ];
  };

  unstable-pkgs = import <nixos-unstable> {config.allowUnfree=true;};
in
{
  imports = [
    ../sway/sway.nix
    ../i3/i3.nix
    ../i3/picom.nix
    ../i3/polybar.nix
    ../i3/rofi.nix
    ../special/cybersecurity.nix
  ];
  home.stateVersion = "24.11";
  fonts.fontconfig.enable = true;

  xdg = {
    enable = true;
  };

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ 
    "terraform" 
    "mongodb-compass"
    "spotify" 
  ];

  home.packages = with pkgs; [
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
    # pulumi
    # jetbrains.phpstorm
    jetbrains.idea-community
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
    mattermost-desktop
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
  ] ++ (if (host-info.ai_enabled) then  [] else [])
  ++ (if (host-info.gpu == "nvidia") then  [unstable-pkgs.ollama-cuda] else []);

  programs.neovim = {
    enable = true;
    package = unstable-pkgs.neovim-unwrapped;
    vimAlias = true;
    withNodeJs = true;
  };

  home.file."./.aider.model.settings.yml".source = ./aider.model.settings.yml;
  home.activation.opencodeSeed = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -e "$HOME/.config/opencode/opencode.json" ]; then
        install -Dm0644 ${./opencode.json} "$HOME/.config/opencode/opencode.json"
      fi
      install -Dm0644 ${./prompts/qwen.txt} "$HOME/.config/opencode/prompts/qwen.txt"
      install -Dm0644 ${./prompts/qwen-coder.txt} "$HOME/.config/opencode/prompts/qwen-coder.txt"
  '';

  home.file.".config/opencode/dev/bin/opencoder-dev".source = ./dev-coder.sh;
  home.file."./.config/nvim/" = {
    source = ./nvim;
    recursive = true;
  };

  home.file."./.config/nvim/lua/flow/init.lua".text = ''
    require("flow.set")
    require("flow.remap")
  '';

  # we hardcode a symlink here so that we can refer to it in our lazy config
  home.file.".config/foot/foot.ini".source = ./foot.ini;
  home.file.".config/alacritty/alacritty.toml".source = ./alacritty.toml;
  home.file.".bashrc".source = ./bashrc;
  home.file."startWm.sh".source = ./startWm.sh;

}
