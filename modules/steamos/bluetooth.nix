{ config, lib, ... }:

let
  inherit (lib)
    mkIf
    mkOption
    types
  ;
  cfg = config.jovian.steamos;
in
{
  options = {
    jovian.steamos = {
      enableBluetoothConfig = mkOption {
        default = cfg.useSteamOSConfig;
        defaultText = lib.literalExpression "config.jovian.steamos.useSteamOSConfig";
        type = types.bool;
        description = lib.mdDoc ''
          Adjust default BlueZ settings to match SteamOS.
        '';
      };
    };
  };

  config = mkIf (cfg.enableBluetoothConfig) {
    # See: https://github.com/Jovian-Experiments/PKGBUILDs-mirror/blob/jupiter-3.5/bluez/0001-valve-bluetooth-config.patch
    hardware.bluetooth.settings = {
      General.MultiProfile = "multiple";
      LE = {
        ScanIntervalSuspend = 2240;
        ScanWindowSuspend = 224;
      };
    };
  };
}
