{ pkgs, lib, ... }:

{
  imports = [
      ../sway/sway.nix
  ];
  fonts.fontconfig.enable = true; 
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "slack"
      "lens-6.3.0"
  ];

  home.stateVersion = "23.05";
  home.packages = with pkgs; [
    # programming
      neovim cargo alacritty git gcc
    # utils cli
      jq pciutils usbutils libmbim pavucontrol htop calcurse dbus neofetch tigervnc wev
    # clouds
      mysql-workbench lens awscli2 google-cloud-sdk-gce
    # utils gui
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
  home.file.".config/alacritty/alacritty.yml".source = ./alacritty.yml;
}
