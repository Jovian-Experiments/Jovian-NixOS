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
        description = ''
          Adjust default BlueZ settings to match SteamOS.
        '';
      };
    };
  };

  config = mkIf (cfg.enableBluetoothConfig) {
    # See: https://github.com/Jovian-Experiments/PKGBUILDs-mirror/tree/jupiter-main/bluez
    hardware.bluetooth.settings = {
      General = {
        MultiProfile = "multiple";
        FastConnectable = true;
        # enable experimental LL privacy, experimental offload codecs
        KernelExperimental = "15c0a148-c273-11ea-b3de-0242ac130004,a6695ace-ee7f-4fb9-881a-5fac66c629af";
      };
      LE = {
        ScanIntervalSuspend = 2240;
        ScanWindowSuspend = 224;
      };
    };
  };
}
