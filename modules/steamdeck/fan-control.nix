{ pkgs, config, lib, ... }:

# Userspace fan control

let
  inherit (lib)
    mkDefault
    mkIf
    mkMerge
    mkOption
    types
  ;
  cfg = config.jovian.devices.steamdeck;

  jupiter-fan-control = pkgs.jupiter-fan-control.override {
    useNewHwmonName = config.boot.kernelPackages.kernelAtLeast "6.0";
  };
in
{
  options = {
    jovian.devices.steamdeck = {
      enableOsFanControl = mkOption {
        description = ''
          Whether to enable the OS-controlled fan curve.

          This is enabled by default since SteamOS 3.2.
        '';
        type = types.bool;
        default = cfg.enable;
      };
    };
  };

  config = mkIf (cfg.enableOsFanControl) {
    systemd.services.jupiter-fan-control = {
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.dmidecode ];
      serviceConfig = {
        ExecStart = "${jupiter-fan-control}/share/jupiter-fan-control/fancontrol.py --run";
        ExecStopPost = "${jupiter-fan-control}/share/jupiter-fan-control/fancontrol.py --stop";
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
