# NixOS Configuration

This repository contains the NixOS configuration for my systems, using a multi-host setup with pinned dependencies via [niv](https://github.com/nmattia/niv).

## Structure

- `configuration.nix` & `hardware-configuration.nix` - Symlinks to current host config
- `nix/` - Pinned dependencies (nixpkgs, nixpkgs-unstable, home-manager)
- `common/` - Shared system and home-manager configurations
- `hosts/` - Host-specific configurations (gengar, gastly, onix)
- `rebuild.sh` - Helper script for rebuilding
- `update.sh` - Helper script for updating pinned dependencies

## Quick Start

```bash
# Rebuild the system
./rebuild.sh switch

# Update all pinned dependencies
./update.sh

# Update a specific dependency
./update.sh nixpkgs-unstable
```

## Managing Hosts

To switch to a different host configuration:

```bash
./symlink.sh <hostname>
./rebuild.sh switch
```

Available hosts: `gengar`, `gastly`, `onix`

## Pinned Dependencies

Dependencies are pinned in `nix/sources.json` using niv:

- **nixpkgs** - NixOS 25.11 stable
- **nixpkgs-unstable** - Latest unstable
- **home-manager** - release-25.11

## Available Scripts

### rebuild.sh

```bash
./rebuild.sh [action]

Actions:
  switch     # Build and activate (default)
  build      # Build only
  test       # Build and activate, don't add to boot
  dry-build  # Test without building
```

### update.sh

```bash
./update.sh [source]

Sources:
  nixpkgs          # Update stable nixpkgs
  nixpkgs-unstable # Update unstable nixpkgs
  home-manager     # Update home-manager
  all              # Update all (default)
```

### symlink.sh

```bash
./symlink.sh <hostname>

# Creates symlinks:
#   configuration.nix -> hosts/<hostname>/configuration.nix
#   hardware-configuration.nix -> hosts/<hostname>/hardware-configuration.nix
```
