{ lib, config, ...}: 
let cfg = config.host-info; in {
  options = {
    host-info.gpu = lib.mkOption {
      type = lib.types.enum ["amd" "nvidia"];
      default = "amd";
      example = "amd";
      description = "Which GPU do you use?";
    };
    host-info.preferred_wm = lib.mkOption {
      type = lib.types.enum ["i3" "sway"];
      default = "sway";
      example = "sway";
      description = "Which WM would you like?";
    };
    host-info.hostname = lib.mkOption {
      type = lib.types.str;
      example = "pikachu";
      description = "Hostname of machine in the form of a pokemon name";
    };
    host-info.ai_enabled = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = false;
      description = "Would you like AI features enabled?";
    };
  };
  config = {

  };
}
