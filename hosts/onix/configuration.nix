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
    ./hosts/onix/alpha-homebank.nix
    ./hardware-configuration.nix
    "${home-manager}/nixos"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "onix";
  networking.nat.enable = true;
  networking.nat.internalInterfaces = [ "ve-+" ];
  networking.nat.externalInterface = "wlp13s0";
  networking.nat.enableIPv6 = true;

  system.stateVersion = "23.05";
}
