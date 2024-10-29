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
      systemd.services."jovian-dmidecode-workaround" = {
        enable = true;
        unitConfig.ConditionPathIsDirectory = "/run";
        before = [ "multi-user.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          #!${pkgs.runtimeShell}
          mkdir -p /run/jovian
          ${pkgs.dmidecode}/bin/dmidecode -t 11 > /run/jovian/dmidecode-11.txt
        '';
      };
    }
  ]);
}
