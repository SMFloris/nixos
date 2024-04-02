{ pkgs, lib, ... }:

{
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
}
