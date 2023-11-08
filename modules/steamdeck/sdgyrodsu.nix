{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkIf
    mkOption
    types
  ;
  cfg = config.jovian.devices.steamdeck;
in
{
  options = {
    jovian.devices.steamdeck = {
      enableGyroDsuService = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable the Cemuhook DSU service for the gyroscope.

          If enabled, motion data from the gyroscope can be used in Cemu
          with Cemuhook.
        '';
      };
    };
  };
  config = mkIf cfg.enableGyroDsuService {
    systemd.user.services.sdgyrodsu = {
      description = "Cemuhook DSU server for the Steam Deck Gyroscope";
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.sdgyrodsu}/bin/sdgyrodsu";
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
      };
    };
  };
}
