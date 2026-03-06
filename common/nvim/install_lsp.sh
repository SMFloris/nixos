#!/usr/bin/env bash

# LSP Server Installation Script for Neovim Profile
echo "Installing LSP servers for Neovim profile..."

# Source the profile environment
PROFILE="$HOME/.nix-profile-neovim"
STATE="$HOME/.local/state/neovim-profile"

# Create directories if they don't exist
mkdir -p "$STATE/npm/bin"
mkdir -p "$PROFILE/bin"

# Set up environment for installation
export CARGO_HOME="$STATE/cargo"
export RUSTUP_HOME="$STATE/rustup"
export NPM_CONFIG_PREFIX="$STATE/npm"
export NODE_PATH="$STATE/npm/lib/node_modules"
export COMPOSER_HOME="$STATE/composer"
export NUGET_PACKAGES="$STATE/nuget"
export PATH="$STATE/npm/bin:$PROFILE/bin:$PATH"

# Check if npm is available
if command -v npm &> /dev/null; then
    echo "Installing vtsls (TypeScript LSP server) to profile..."
    npm install -g @vtsls/language-server
    
    echo "Installing Pyright to profile..."
    npm install -g pyright
    
    echo "Installing YAML Language Server to profile..."
    npm install -g yaml-language-server
else
    echo "npm not found. Please install Node.js and npm first."
fi

# Check if nix is available for Nix LSP servers
if command -v nix &> /dev/null; then
    echo "Installing Nix LSP server (nil) to profile..."
    nix profile install nixpkgs#nil --profile "$PROFILE"
    
    echo "Installing Lua LSP server to profile..."
    nix profile install nixpkgs#lua-language-server --profile "$PROFILE"
else
    echo "Nix not found. Skipping nil and lua-language-server installation."
fi

echo "Installation complete!"
echo ""
echo "LSP servers installed to your Neovim profile:"
echo "  Profile: $PROFILE"
echo "  State: $STATE"
echo ""
echo "To verify installation, run:"
echo "  ls $STATE/npm/bin/ | grep -E '(vtsls|pyright|yaml-language-server)'"
echo "  ls $PROFILE/bin/ | grep -E '(nil|lua-language-server)'"
echo ""
echo "Then restart Neovim to enable the LSP servers."
