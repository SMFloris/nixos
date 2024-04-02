{ pkgs, lib, ... }:

let 
   thunarWithPlugins = pkgs.xfce.thunar.override {
          thunarPlugins = [pkgs.xfce.thunar-volman pkgs.xfce.thunar-archive-plugin];
  };
in
{
  imports = [
      ../sway/sway.nix
      ../special/unfree.nix
      ../special/cybersecurity.nix
  ];
  home.stateVersion = "23.05";
  fonts.fontconfig.enable = true; 
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "terraform"
      "slack"
      "postman"
      "mongodb-compass"
      "obsidian"
  ];
  nixpkgs.config.permittedInsecurePackages = [
                "electron-25.9.0"
              ];
  services.gnome-keyring = {
    enable = true;
    components = ["pkcs11" "secrets" "ssh"];
  };
  home.packages = with pkgs; [
    # programming
      neovim cargo nodejs foot git gcc ollama
    # utils cli
      ripgrep jq pciutils usbutils libmbim pavucontrol htop calcurse dbus neofetch tigervnc 
    # clouds
      terraform kubectl mysql-workbench mongodb-compass openlens awscli2 google-cloud-sdk-gce
    # utils gui
      evince
      wdisplays
      insomnia
      system-config-printer
      meld
      octave
      libreoffice
      obsidian
    # comms
      slack
    # sync
      maestral
      maestral-gui
    # keyboard
      ttyper
      wev vial qmk
    # extra
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
  ];
  home.file.".config/nvim" = {
	  recursive = true;
  	source = builtins.fetchGit {
		  url = "https://github.com/AstroNvim/AstroNvim";
		  rev = "8fe945f07aebf8dd2006e7cb3f89c200e0e4adef";
	  };
  };
  home.file.".config/nvim/lua/user" = {
    recursive = true;
    source = builtins.fetchGit {
		  url = "https://github.com/SMFloris/astronvim-config";
		  # url = "/home/flow/Projects/astronvim-config";
		  ref = "try_orgmode";
	  };
  };
  home.file.".config/nvim/syntax/c3.vim".source = ./vim/syntax/c3.vim;
  # home.file.".config/alacritty/alacritty.yml".source = ./alacritty.yml;
  home.file.".config/foot/foot.ini".source = ./foot.ini;
}
