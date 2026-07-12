# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, lib, ... }:

let
  sources = import ./npins;
  nixpkgs = sources.nixpkgs;
  nixpkgs-unstable = sources.nixpkgs-unstable;
  home-manager = sources.home-manager;

  fccUnlockScript = pkgs.writeScript "fcc-unlock.sh" ''
     #!/run/current-system/sw/bin/bash
     dbus_path=$1
     shift
     ports=("$@")
     for port in "''${ports[@]}"; do
       if [[ $port =~ mbim ]]; then
         device="/dev/$port"
         mbimcli -p -d "$device" -v --quectel-set-radio-state=on
         break
       fi
     done
   '';
in

{

  nix.nixPath = [
    "nixpkgs=${nixpkgs}"
    "nixos-unstable=${nixpkgs-unstable}"
    "home-manager=${home-manager}"
    "nixos-config=/etc/nixos/configuration.nix"
  ];

  imports =
    [
      ./common/common.nix
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      "${home-manager}/nixos"
    ];

  environment.variables = {
    WINIT_X11_SCALE_FACTOR = "1.2";
  };
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "gengar"; # Define your hostname.
  networking.nat.enable = true;
  networking.nat.internalInterfaces = ["ve-+"];
  networking.nat.externalInterface = "wlp1s0";
  networking.nat.enableIPv6 = true;

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  systemd.services.ModemManager = {
    aliases = [ "dbus-org.freedesktop.ModemManager1.service" ];
    wantedBy = [ "multi-user.target" "network.target" ];
    enable = true;
    path = [ pkgs.libqmi ];
  };

  networking.modemmanager.fccUnlockScripts = [
    {id = "1eac:1007"; path = "${fccUnlockScript}";}
  ];

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}

