{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkOption
    types
    elem
    mkIf
    optionals
    ;

  cfg = config.jovian.steam.inputMethod;
in
{
  options = {
    jovian = {
      steam = {
        inputMethod = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = ''
              Whether to enable the Steam IM support.

              Enable this if you want to enable Steam IM support.
              This will also set system wide input method to `ibus`.
            '';
          };
          methods = mkOption {
            type = types.listOf types.str;
            default = [ ];
            example = [ "pinyin" "japanese" "korean" ];
            description = ''
              List of input methods to enable.

              This option is only used when `enable` is set to `true`.
            '';
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      steam-im-modules
    ];

    i18n.inputMethod = {
      enable = true;
      type = "ibus";
      ibus = {
        engines = with pkgs.ibus-engines;
          optionals (elem "pinyin" cfg.methods) [ pinyin ]
          ++ optionals (elem "japanese" cfg.methods) [ anthy ]
          ++ optionals (elem "korean" cfg.methods) [ hangul ];
      };
    };
  };
}
