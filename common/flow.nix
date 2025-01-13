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
  my-c3-lsp = pkgs.stdenv.mkDerivation {
    name = "c3-lsp";
    sourceRoot = "c3-lsp";
    srcs = [
      (pkgs.fetchFromGitHub {
        name = "c3-lsp";
        owner = "pherrymason";
        repo = "c3-lsp";
        rev = "refs/tags/v0.3.2";
        sha256 =  "sha256-HD3NE2L1ge0pf8vtrKkYh4GIZg6lSPTZGFQ+LPbDup4=";
      })
      (pkgs.fetchFromGitHub {
        name = "c3c";
        owner = "c3lang";
        repo = "c3c";
        rev = "refs/tags/v0.6.4";
        sha256 =  "sha256-nSsNLde9jK+GgSp6DXXmD31+un7peK6t/vnzM7hZDFg=";
       })
      (pkgs.fetchFromGitHub {
        name = "tree-sitter-c3";
        owner = "c3lang";
        repo = "tree-sitter-c3";
        rev = "ef09c89e498b70e4dfbf81d00e8f4086fa8d1c0a";
        sha256 = "sha256-55sX+yMEa0PAUZ2Vym8rbOCE7KyJowv7amiUm0xA6Lg=";
        # sha256 =  "sha256-nSsNLde9jK+GgSp6DXXmD31+un7peK6t/vnzM7hZDFg=";
        # sha256 =  "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
       })
    ];
    buildInputs = [
      pkgs.nodejs
      pkgs.tree-sitter
      pkgs.go
    ];
    preBuild = ''
      mkdir -p assets
      cp -r ../c3c ./assets/
      cp -r ../tree-sitter-c3 ./assets/
      substituteInPlace Makefile --replace git echo
      substituteInPlace Makefile --replace "tree-sitter generate" echo
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      GOPATH=/tmp GOCACHE=/tmp/go-cache GOOS=linux GOARCH=amd64 CGO_ENABLED=1 go build -C server/cmd/lsp -o $out/bin/c3lsp
      runHook postInstall
    '';
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
    jetbrains.phpstorm
    fzf
    my-c3c
    my-c3-lsp
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
