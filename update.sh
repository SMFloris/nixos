#!/usr/bin/env bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Available sources
SOURCES=("nixpkgs" "nixpkgs-unstable" "home-manager")

show_help() {
    echo "Usage: $0 [SOURCE]"
    echo ""
    echo "Update niv-managed dependencies for NixOS configuration"
    echo ""
    echo "Available sources:"
    for src in "${SOURCES[@]}"; do
        echo "  - $src"
    done
    echo "  - all (update all sources)"
    echo ""
    echo "Examples:"
    echo "  $0 nixpkgs           # Update only nixpkgs"
    echo "  $0 nixpkgs-unstable  # Update only nixpkgs-unstable"
    echo "  $0 home-manager      # Update only home-manager"
    echo "  $0 all               # Update all sources"
    echo "  $0                   # Update all sources (default)"
}

# Show help if requested
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

TARGET="${1:-all}"

# Validate target
if [[ "$TARGET" != "all" ]]; then
    valid=false
    for src in "${SOURCES[@]}"; do
        if [[ "$src" == "$TARGET" ]]; then
            valid=true
            break
        fi
    done
    
    if [[ "$valid" == false ]]; then
        echo "Error: Unknown source '$TARGET'"
        show_help
        exit 1
    fi
fi

echo "Updating dependencies using niv..."
echo ""

if [[ "$TARGET" == "all" ]]; then
    echo "Updating all sources..."
    niv update
else
    echo "Updating $TARGET..."
    niv update "$TARGET"
fi

echo ""
echo "Done! Updated sources.json"
echo "Run 'sudo nixos-rebuild switch' to apply changes"
