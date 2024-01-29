{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkIf
    mkMerge
    mkOption
    types
    ;
  cfg = config.jovian.devices.steamdeck;
in
{
  options = {
    jovian.devices.steamdeck = {
      enableBluetooth = mkOption {
        type = types.bool;
        default = cfg.enable;
        defaultText = lib.literalExpression "config.jovian.devices.steamdeck.enable";
        description = ''
          Whether to enable bluetooth.
        '';
      };
    };
  };
  config = mkMerge [
    (mkIf (cfg.enableBluetooth) {
      hardware.bluetooth.enable = true;
    })
  ];
}
