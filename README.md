# NixOS Configuration

This repository contains the NixOS configuration for my systems, including system-level settings, home-manager configurations, 
and customizations for development and productivity tools.

## 📝 Overview

This configuration defines a NixOS system with the following key features:

- **System Setup**: Uses `systemd-boot` as the bootloader and includes hardware configuration.
- **Home Manager**: Manages user-specific configurations (e.g., Neovim, fonts, shell).
- **Window Manager**: Supports both Sway (Wayland) and i3 (X11) window managers.
- **Custom Packages**: Includes a wide range of development tools, utilities, and GUI applications.
- **Neovim Integration**: Configures Neovim with treesitter, LSP, and custom keybindings.
- **GPU Support**: Configurable for both AMD and NVIDIA GPUs.
- **AI Features**: Optional AI integration via `ollama-cuda` for NVIDIA GPUs.

## 🧱 Key Components

### 1. **System Configuration**

### 2. **Hosts**
- **`onix`**: Primary development machine with Wayland (Sway) support.
- **`gastly`**: Secondary machine optimized for X11 (i3) with specific hardware configurations.
- Uses `nixos-unstable` for access to the latest packages.
- Includes hardware-specific configuration via `hardware-configuration.nix`.
- Sets the hostname to `onix`.

### 2. **Home Manager**
- Manages user-specific settings and packages.
- Includes custom Neovim configuration and treesitter setup.
- Sets up fonts and terminal configurations.

### 3. **Window Manager**
- Supports both Sway and i3 window managers.
- Includes configurations for `picom`, `rofi`, `polybar`, and `thunar`.

### 4. **Development Tools**
- Programming languages: Go, Rust, Python, JavaScript, TypeScript, etc.
- Editors: Neovim with LSP and treesitter.
- CLI tools: `ripgrep`, `fd`, `lazygit`, `k9s`, `tmux`, `nodejs`, `rust-analyzer`, etc.
- GUI tools: `libreoffice`, `blender`, `gimp`, `spotify`, `evince`, `meld`, `octave`, etc.

### 5. **Custom Packages**
- Includes custom builds for `c3c`, `c3-lsp`, and `godot-4`.
- Uses unstable versions of some tools (e.g., `ollama-cuda` for NVIDIA GPUs).

## 📦 Installed Software

### 📦 CLI Tools
- `ripgrep`, `fd`, `lazygit`, `k9s`, `tmux`, `git`, `nodejs`, `rust-analyzer`, `black`, `jq`, `yq`, `fzf`, `neofetch`, `tmux`, `cargo`, `nodejs_22`, etc.

### 📦 GUI Applications
- `libreoffice`, `blender`, `gimp`, `spotify`, `evince`, `meld`, `octave`, `bruno`, `insomnia`, `gnome-disk-utility`, `system-config-printer`, etc.

### 📦 Development
- Go, Rust, Python, Node.js, Terraform, Kubernetes tools, Docker, `c3c`, `c3-lsp`, `godot-4`, etc.

### 📦 Utilities
- `btop`, `calcurse`, `pavucontrol`, `tigervnc`, `easyocr`, `maestral`, `gamescope`, `networkmanagerapplet`, `transmission_4-gtk`, etc.

## 🧩 Configuration Details

- **Neovim**: Uses `nvim-treesitter` with many language parsers and custom keybindings.
- **Fonts**: Enabled `fontconfig` for better font rendering.
- **Terminal**: Uses `foot` as the default terminal emulator.
- **Shell**: Custom `.bashrc` and startup script `startWm.sh`.
- **Window Manager**: Supports both Sway (Wayland) and i3 (X11) window managers.
- **GPU**: Configurable for AMD or NVIDIA GPUs, with optional AI features via `ollama-cuda`.

This setup is tailored for a developer environment with a focus on productivity, customization, and access to the latest tools.
