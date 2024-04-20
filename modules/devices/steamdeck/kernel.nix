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
      # HACK: block simpledrm from loading, so that the real GPU always gets card0,
      # as that's where Steam currently assumes it's going to be. Bad Steam, bad.
      boot.kernelParams = ["initcall_blacklist=simpledrm_platform_driver_init"];
      boot.kernelPackages = mkDefault pkgs.linuxPackages_jovian;
    }
  ]);
}
