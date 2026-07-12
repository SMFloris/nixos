# NixOS Configuration

This repository contains the NixOS configuration for my systems, using a
multi-host setup with pinned dependencies via
[npins](https://github.com/andir/npins).

## Structure

- `configuration.nix` & `hardware-configuration.nix` - Symlinks to current host
  config
- `npins/` - Pinned dependencies (nixpkgs, nixpkgs-unstable, home-manager)
- `common/` - Shared system and home-manager configurations
- `hosts/` - Host-specific configurations (gengar, gastly, onix)
- `rebuild.sh` - Helper script for rebuilding

## Quick Start

```bash
# Rebuild the system
./rebuild.sh switch
```

## Managing Hosts

To switch to a different host configuration:

```bash
./symlink.sh <hostname>
./rebuild.sh switch
```

Available hosts: `gengar`, `gastly`, `onix`

## Pinned Dependencies

Dependencies are pinned in `npins/sources.json` using npins.

## New Host

Either use an existing host as a base or create a new one completely.

Steps:

1. Install NixOs
2. Make /etc/nixos belong to your user (chown -R <user>:users /etc/nixos) 
3. First: nixos-rebuild switch first
4. Backup configuration.nix/hardware-configuration.nix
5. Empty /etc/nixos
6. Do `git clone https://github.com/SMFloris/nixos.git .`
7. Add your configuration.nix/hardware-configuration.nix to hosts folder. Here
   make sure you follow the conventions for npins and nixpaths. Take
   inspiration from @hosts/gengear/configuration.nix
8. Do `./symlink.sh <hostname>`
9. Do `./rebuild.sh switch`
10. You can now remove channels completely `sudo nix-channel --list` and `sudo nix-channel --remove <channel>`

## Updating

Just use `npins update` and `npins upgrade`
