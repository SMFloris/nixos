{ config, pkgs, lib, ... }:

let
  thunarWithPlugins = pkgs.xfce.thunar.override {
    thunarPlugins = [ pkgs.xfce.thunar-volman pkgs.xfce.thunar-archive-plugin ];
  };
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
  home.stateVersion = "23.05";
  fonts.fontconfig.enable = true;
  services.gnome-keyring = {
    enable = true;
    components = [ "pkcs11" "secrets" "ssh" ];
  };

  home.packages = with pkgs; [
    # programming
    unstable-pkgs.neovim
    cargo
    nodejs
    foot
    git
    gcc
    pulumi
    jetbrains.phpstorm
    c3c
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
    openlens
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
    gnome.gnome-clocks
    gnome.file-roller
    thunarWithPlugins
    xfce.ristretto
    xfce.thunar-volman
    xfce.thunar-archive-plugin
    sway-contrib.grimshot
    gnome.gnome-calculator
    gnome.gnome-disk-utility
    gnome.simple-scan
    networkmanagerapplet
    transmission-gtk
    hexchat
    gImageReader
    (builtins.getFlake "github:outfoxxed/quickshell").packages.${builtins.currentSystem}.default
  ] ++ (if (config.host-info.ai_enabled) then  [(pkgs.callPackage (import ./packages/fabric.nix) {})] else [])
  ++ (if (config.host-info.gpu == "nvidia") then  [unstable-pkgs.ollama-cuda] else []);

  home.file.".config/nvim" = {
    recursive = true;
    source = builtins.fetchGit {
      # url = "https://github.com/SMFloris/nvim-config";
      url = "/home/flow/Projects/personal/nvim-config";
      ref = "master";
    };
  };
  home.file.".config/foot/foot.ini".source = ./foot.ini;
  home.file.".bashrc".source = ./bashrc;
  home.file."startWm.sh".source = ./startWm.sh;

}
