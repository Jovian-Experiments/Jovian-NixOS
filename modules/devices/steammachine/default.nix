# Steam Machine-specific configurations
#
# jovian.devices.steammachine

{ config, lib, ... }:

let
  inherit (lib)
    mkIf
    mkOption
    types
  ;
  cfg = config.jovian.devices.steammachine;
in
{
  imports = [
    ./kernel.nix
    ./firmware.nix
  ];

  options = {
    jovian.devices.steammachine = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable Steam Machine-specific configurations.
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    jovian.hardware.has = {
      amd.gpu = true;
    };
  };
}
