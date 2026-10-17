{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkIf
    mkMerge
    mkOption
    types
  ;
  cfg = config.jovian.steamos;
in
{
  options = {
    jovian.steamos = {
      enableOsFanControl = mkOption {
        description = ''
          Whether to enable the OS-controlled fan curve.

          This is enabled by default since SteamOS 3.2.
        '';
        type = types.bool;
        default = cfg.useSteamOSConfig;
        defaultText = lib.literalExpression "config.jovian.steamos.useSteamOSConfig";
      };
    };
  };

  config = mkIf (cfg.enableOsFanControl) {
    systemd.services.jupiter-fan-control = {
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.dmidecode ];
      serviceConfig = {
        ExecStart = "${pkgs.jupiter-fan-control}/share/jupiter-fan-control/fancontrol.py --run";
        ExecStopPost = "${pkgs.jupiter-fan-control}/share/jupiter-fan-control/fancontrol.py --stop";
        OOMScoreAdjust = -1000;
        Restart = "on-failure";

        # disable debug journal logging
        StandardOutput = "null";
      };
      environment = {
        PYTHONUNBUFFERED = "1";
      };
    };
  };
}
