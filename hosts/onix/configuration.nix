{ ... }:

let 
  sources = import ./npins;
  nixpkgs = sources.nixpkgs;
  nixpkgs-unstable = sources.nixpkgs-unstable;
  home-manager = sources.home-manager;
in {
  nix.nixPath = [
    "nixpkgs=${nixpkgs}"
    "nixos-unstable=${nixpkgs-unstable}"
    "home-manager=${home-manager}"
    "nixos-config=/etc/nixos/configuration.nix"
  ];

  imports = [
    ./pinning.nix
    ./common/common.nix
    ./common/kyria.nix
    ./hosts/onix/alpha-homebank.nix
    ./hardware-configuration.nix
    "${home-manager}/nixos"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "onix";

  # Disable Wi-Fi power saving while investigating RTL8852CE stalls.
  networking.networkmanager.wifi.powersave = false;
  boot.extraModprobeConfig = ''
    options rtw89_core disable_ps_mode=Y
  '';

  networking.nat.enable = true;
  networking.nat.internalInterfaces = [ "ve-+" ];
  networking.nat.externalInterface = "wlp13s0";
  networking.nat.enableIPv6 = true;

  system.stateVersion = "23.05";
}
