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
      enableDeviceDataWorkarounds = mkOption {
        type = types.bool;
        default = cfg.enable;
        defaultText = lib.literalExpression "config.jovian.devices.steamdeck.enable";
        description = ''
          Whether to add some workarounds for (Steam Deck) device-specific data.
        '';
        # Don't expose to users.
        internal = true;
        readOnly = true;
      };
    };
  };
  config = mkIf (cfg.enableDeviceDataWorkarounds) (mkMerge [
    {
      # z - adjust permissions
      systemd.tmpfiles.settings."99-jovian"."/sys/firmware/dmi/tables/*".z.mode = "444";
    }
  ]);
}
