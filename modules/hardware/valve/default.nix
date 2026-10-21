{ config, lib, ... }:
let
  cfg = config.jovian.hardware.valve;
in
{
  imports = [
    ./fan-control.nix
    ./sound.nix
  ];

  options = {
    jovian.hardware.valve.enable = lib.mkEnableOption "drivers and additional configuration specific to Valve hardware";
  };

  config = lib.mkIf cfg.enable {
    jovian.steamos = {
      enableVendorKernel = true;
      enableVendorMesa = true;
    };
  };
}
