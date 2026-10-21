{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.jovian.hardware.valve;
in
{
  options = {
    jovian.hardware.valve.fan-control.enable = lib.mkOption {
      default = cfg.enable;
      defaultText = "config.jovian.hardware.valve.enable";
      description = ''
        Whether to enable software fan controls for Valve hardware.

        This is generally a no-op on non-Valve devices.
      '';
      type = lib.types.bool;
    };
  };

  config = lib.mkIf (cfg.fan-control.enable) {
    systemd.services.jupiter-fan-control = {
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.dmidecode ];
      serviceConfig = {
        ExecStart = "${pkgs.jovianPackages.jupiter-fan-control}/share/jupiter-fan-control/fancontrol.py --run";
        ExecStopPost = "${pkgs.jovianPackages.jupiter-fan-control}/share/jupiter-fan-control/fancontrol.py --stop";
        OOMScoreAdjust = -1000;
        Restart = "on-failure";

        # disable debug journal logging
        StandardOutput = "null";
      };
      environment.PYTHONUNBUFFERED = "1";
    };
  };
}
