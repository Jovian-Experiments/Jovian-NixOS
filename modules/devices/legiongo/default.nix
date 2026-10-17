# Legion Go-specific configurations
#
# jovian.devices.legiongo

{ config, lib, ... }:

let
  inherit (lib)
    mkIf
    mkOption
    types
  ;
  cfg = config.jovian.devices.legiongo;
in
{
  imports = [
  ];

  options = {
    jovian.devices.legiongo = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable Legion Go-specific configurations.
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    jovian.hardware.has = {
      amd.gpu = true;
      nonNativePaddles = true;
    };
  };
}
