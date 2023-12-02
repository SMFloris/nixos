{ pkgs, lib, ... }:

{
  imports = [
      ../sway/sway.nix
  ];
  home.stateVersion = "23.05";
  fonts.fontconfig.enable = true; 
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "terraform"
      "slack"
      "postman"
      "mongodb-compass"
  ];
  services.gnome-keyring = {
    enable = true;
    components = ["pkcs11" "secrets" "ssh"];
  };
  home.packages = with pkgs; [
    # programming
      neovim cargo nodejs foot git gcc
    # utils cli
      ripgrep jq pciutils usbutils libmbim pavucontrol htop calcurse dbus neofetch tigervnc wev
    # clouds
      terraform kubectl mysql-workbench mongodb-compass openlens awscli2 google-cloud-sdk-gce
    # utils gui
      system-config-printer
      meld
      octave
      libreoffice
    # comms
      slack
    # sync
      maestral
      maestral-gui
    # extra
      xfce.thunar
      xfce.thunar-volman
      sway-contrib.grimshot
      gnome.gnome-calculator
      gnome.gnome-disk-utility
      networkmanagerapplet
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
