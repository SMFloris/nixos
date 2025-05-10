{ config, pkgs, lib, ... }:

let
  treesitterWithGrammars = (pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [
    p.bash
    p.comment
    p.css
    p.dockerfile
    p.fish
    p.gitattributes
    p.gitignore
    p.go
    p.gomod
    p.gowork
    p.hcl
    p.javascript
    p.jq
    p.json5
    p.json
    p.lua
    p.make
    p.markdown
    p.nix
    p.python
    p.rust
    p.toml
    p.typescript
    p.vue
    p.yaml
  ]));

  treesitter-parsers = pkgs.symlinkJoin {
    name = "treesitter-parsers";
    paths = treesitterWithGrammars.dependencies;
  };

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

  xdg = {
    enable = true;
  };

  home.packages = with pkgs; [
    # neovim
    ripgrep
    fd
    lua-language-server
    rust-analyzer-unwrapped
    lazygit
    black
    nodejs_22
    # programming
    k9s
    tmux
    gcr
    cargo
    nodejs
    foot
    git
    gcc
    # pulumi
    # jetbrains.phpstorm
    jetbrains.idea-community
    fzf
    my-c3c
    c3-lsp
    godot_4
    # utils cli
    bc
    jq
    yq-go
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
  ] ++ (if (config.host-info.ai_enabled) then  [] else [])
  ++ (if (config.host-info.gpu == "nvidia") then  [unstable-pkgs.ollama-cuda] else []);

  programs.neovim = {
    enable = true;
    package = unstable-pkgs.neovim-unwrapped;
    vimAlias = true;
    withNodeJs = true;

    plugins = [
      treesitterWithGrammars
    ];
  };

  home.file."./.config/nvim/" = {
    source = ./nvim;
    recursive = true;
  };

  home.file."./.config/nvim/lua/flow/init.lua".text = ''
    require("flow.set")
    require("flow.remap")
    vim.opt.runtimepath:append("${treesitter-parsers}")
  '';

  # Treesitter is configured as a locally developed module in lazy.nvim
  # we hardcode a symlink here so that we can refer to it in our lazy config
  home.file."./.local/share/nvim/nix/nvim-treesitter/" = {
    recursive = true;
    source = treesitterWithGrammars;
  };
  home.file.".config/foot/foot.ini".source = ./foot.ini;
  home.file.".config/alacritty/alacritty.toml".source = ./alacritty.toml;
  home.file.".bashrc".source = ./bashrc;
  home.file."startWm.sh".source = ./startWm.sh;

}
