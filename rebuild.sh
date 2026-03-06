#!/usr/bin/env bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Show help
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: $0 [switch|build|test|dry-build|...]"
    echo ""
    echo "Rebuild NixOS configuration with pinned nixpkgs"
    echo ""
    echo "Examples:"
    echo "  $0           # Run 'nixos-rebuild switch'"
    echo "  $0 build     # Run 'nixos-rebuild build'"
    echo "  $0 dry-build # Run 'nixos-rebuild dry-build' (test without building)"
    echo "  $0 test      # Run 'nixos-rebuild test' (build and activate, don't add to boot menu)"
    echo ""
    exit 0
fi

# Default action is 'switch'
ACTION="${1:-switch}"

echo "Rebuilding NixOS configuration..."
echo "Action: $ACTION"
echo ""

sudo nixos-rebuild "$ACTION" -I "nixos-config=$SCRIPT_DIR/configuration.nix"
