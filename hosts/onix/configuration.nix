{ ... }:

let 
    sources = import ./npins;
    home-manager = import sources.home-manager {};
in {
  imports = [
    ./pinning.nix
    ./common/common.nix
    ./hardware-configuration.nix
    home-manager.nixos
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
