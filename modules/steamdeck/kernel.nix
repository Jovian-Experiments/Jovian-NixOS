{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkDefault
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
      enableKernelPatches = mkOption {
        type = types.bool;
        default = cfg.enable;
        description = ''
          Whether to apply kernel patches if available.
        '';
      };
    };
  };
  config = mkIf (cfg.enableKernelPatches) (mkMerge [
    {
      boot.kernelPackages = mkDefault pkgs.linuxPackages_jovian;
    }
  ]);
}
