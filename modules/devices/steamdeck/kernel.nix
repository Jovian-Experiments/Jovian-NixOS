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
        defaultText = lib.literalExpression "config.jovian.devices.steamdeck.enable";
        description = ''
          Whether to apply kernel patches if available.
        '';
      };
    };
  };
  config = mkIf (cfg.enableKernelPatches) (mkMerge [
    {
      boot.kernelPackages = mkDefault pkgs.linuxPackages_jovian;
      # see https://github.com/Jovian-Experiments/steamos-customizations-jupiter/blob/jupiter-20240709.1/misc/modules-load.d/hid-playstation.conf
      boot.kernelModules = ["hid_playstation"];
    }
  ]);
}
