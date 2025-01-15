{ config, pkgs, lib, ... }:

let
  thunarWithPlugins = pkgs.xfce.thunar.override {
    thunarPlugins = [ pkgs.xfce.thunar-volman pkgs.xfce.thunar-archive-plugin ];
  };
  my-c3c = pkgs.c3c.overrideAttrs (prev: final: {
    version = "0.6.5";
    src = pkgs.fetchFromGitHub {
      owner = "c3lang";
      repo = "c3c";
      rev = "refs/tags/v0.6.5";
      sha256 =  "sha256-2OxUHnmFtT/TunfO+fOBOrkaHKlnqpO1wJWs79wkvAY=";
    };
  });
  unstable-pkgs = import <nixos-unstable> {config.allowUnfree=true;};
in
{
  imports = [
    (import ../sway/sway.nix {inherit config pkgs lib;})
    (import ../i3/i3.nix {inherit config pkgs lib;})
    (import ../i3/picom.nix {inherit config pkgs lib;})
    (import ../i3/polybar.nix {inherit config pkgs lib;})
    (import ../i3/rofi.nix {inherit config pkgs lib;})
    ../special/cybersecurity.nix
  ];
  home.stateVersion = "24.11";
  fonts.fontconfig.enable = true;
  # services.gnome-keyring = {
  #   enable = true;
  #   components = [ "pkcs11" "secrets" "ssh" ];
  # };

  home.packages = with pkgs; [
    # programming
    k9s
    tmux
    gcr
    unstable-pkgs.neovim
    cargo
    nodejs
    foot
    git
    gcc
    # pulumi
    # jetbrains.phpstorm
    fzf
    my-c3c
    c3-lsp
    godot_4
    # utils cli
    fd
    ripgrep
    jq
    pciutils
    usbutils
    libmbim
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
    pkgs.gnome-clocks
    file-roller
    thunarWithPlugins
    xfce.ristretto
    xfce.thunar-volman
    xfce.thunar-archive-plugin
    sway-contrib.grimshot
    gnome-calculator
    gnome-disk-utility
    simple-scan
    networkmanagerapplet
    transmission_4-gtk
    hexchat
    gImageReader
  ] ++ (if (config.host-info.ai_enabled) then  [] else [])
  ++ (if (config.host-info.gpu == "nvidia") then  [unstable-pkgs.ollama-cuda] else []);

  home.file.".config/nvim" = {
    recursive = true;
    source = builtins.fetchGit {
      url = "https://github.com/SMFloris/nvim-config";
      # url = "/home/flow/Projects/new-nvim-config";
      ref = "master";
    };
  };
  home.file.".config/foot/foot.ini".source = ./foot.ini;
  home.file.".config/alacritty/alacritty.toml".source = ./alacritty.toml;
  home.file.".bashrc".source = ./bashrc;
  home.file."startWm.sh".source = ./startWm.sh;

}
