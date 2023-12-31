{ config, lib, ... }:

let
  inherit (lib)
    mkIf
    mkMerge
    mkEnableOption
    mkOption
    types
  ;
  cfg = config.jovian.hardware.amd;
  hardware = config.jovian.hardware;
  mkHasOption = description: mkOption {
    default = false;
    type = lib.types.bool;
    description = ''
      Whether the device has ${description}.
    '';
  };
in
{
  options = {
    jovian.hardware.has.amd.gpu = mkHasOption "an AMD GPU";
    jovian.hardware.amd = {
      gpu = {
        enableEarlyModesetting = mkOption {
          default = hardware.has.amd.gpu;
          defaultText = lib.literalExpression "config.jovian.hardware.has.amd.gpu";
          type = lib.types.bool;
          description = ''
            Whether to enable early kernel modesetting.
          '';
        };
      };
    };
  };
  config = mkMerge [
    (mkIf cfg.gpu.enableEarlyModesetting {
      boot.initrd.kernelModules = [
        "amdgpu"
      ];
      # Firmware is required in stage-1 for early KMS.
      hardware.enableRedistributableFirmware = true;
    })
  ];
}
