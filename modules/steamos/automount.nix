{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkForce
    mkIf
    mkMerge
    mkOption
    types
  ;
  cfg = config.jovian.steamos;
in
{
  options = {
    jovian.steamos = {
      enableAutoMountUdevRules = mkOption {
        default = cfg.useSteamOSConfig;
        defaultText = lib.literalExpression "config.jovian.steamos.useSteamOSConfig";
        type = types.bool;
        description = ''
          Whether to enable udev rules to automatically mount SD cards upon insertion.
        '';
      };
    };
  };
  config = mkMerge [
    (mkIf (cfg.enableAutoMountUdevRules) {
      jovian.overlay.enable = mkForce true;

      services.udev.packages = [
        pkgs.jupiter-hw-support
      ];
    })
  ];
}
