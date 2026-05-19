{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf mkOption mkDefault types;

  cfg = config.programs.neonix;

  neonix = import ./neonix.nix {
    inherit pkgs lib;
    packageSets = cfg.packageSets;
    ensureInstalled = cfg.ensureInstalled;
    nvimPackage = cfg.nvimPackage;
    nvimConfigPath = cfg.nvimConfigPath;
    nvimProfileName = cfg.nvimProfileName;
    impureNpmPackage = cfg.impureNpmPackage;
    impureCargoPackage = cfg.impureCargoPackage;
    impureNugetPackage = cfg.impureNugetPackage;
    impureComposerPackage = cfg.impureComposerPackage;
    impureLuaRocksPackage = cfg.impureLuaRocksPackage;
  };
in
{
  options.programs.neonix = {
    enable = mkEnableOption "Neonix Neovim wrapper";

    packageSets = mkOption {
      type = types.attrsOf types.raw;
      default = { pkgs = pkgs; };
      description = "Package sets available for \$\{...\} interpolation inside the nvim config.";
    };

    ensureInstalled = mkOption {
      type = types.listOf types.str;
      default = [ "pkgs.hello" ];
      description = "Extra package references to install into the Neonix profile.";
    };

    nvimPackage = mkOption {
      type = types.package;
      default = pkgs.neovim;
      description = "Base Neovim package to wrap.";
    };

    nvimConfigPath = mkOption {
      type = types.path;
      default = ./nvim;
      description = "Path to the source nvim config directory.";
    };

    nvimProfileName = mkOption {
      type = types.str;
      default = "neonix";
      description = "Profile name used for Neonix state and nix profile installation.";
    };

    impureNpmPackage = mkOption {
      type = types.nullOr types.package;
      default = pkgs.nodejs;
      description = "Enable wrapped npm with a per-profile prefix.";
    };

    impureCargoPackage = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = "Enable wrapped cargo with per-profile CARGO_HOME/RUSTUP_HOME.";
    };

    impureNugetPackage = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = "Enable wrapped nuget with a per-profile package directory.";
    };

    impureComposerPackage = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = "Enable wrapped composer with a per-profile COMPOSER_HOME.";
    };

    impureLuaRocksPackage = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = "Reserved for LuaRocks support.";
    };

    enableVimAlias = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable the vim alias in programs.neovim.";
    };

    enableNodeJs = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable Node.js support in programs.neovim.";
    };
  };

  config = mkIf cfg.enable {
    programs.neovim = {
      enable = mkDefault true;
      package = mkDefault neonix.nvim-wrapped;
      vimAlias = mkDefault cfg.enableVimAlias;
      withNodeJs = mkDefault cfg.enableNodeJs;
    };

    home.file.".config/nvim".source = neonix.nvim-config;

    home.activation.neonix =
      lib.hm.dag.entryAfter [ "writeBoundary" ] neonix.nvim-activation;
  };
}
