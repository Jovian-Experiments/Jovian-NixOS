{ config, lib, ... }:

let
  inherit (lib)
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
      enableDefaultCmdlineConfig = mkOption {
        default = cfg.useSteamOSConfig;
        defaultText = lib.literalExpression "config.jovian.steamos.useSteamOSConfig";
        type = types.bool;
        description = ''
          Whether to enable SteamOS kernel command line flags.
        '';
      };
    };
  };
  config = mkMerge [
    (mkIf (cfg.enableDefaultCmdlineConfig) {
      boot.kernelParams = [
        # From grub-steamos in jupiter-hw-support
        #  - https://github.com/Jovian-Experiments/jupiter-hw-support/blob/jupiter-20231212.1/etc/default/grub-steamos
        "amd_iommu=off"
        "amdgpu.gttsize=8128"
        "audit=0"
      ];
    })
  ];
}
