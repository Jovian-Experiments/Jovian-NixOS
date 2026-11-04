{
  config,
  lib,
  pkgs,
  ...
}:

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
      boot.kernelPackages = mkDefault pkgs.jovianPackages.linuxPackages;
      # see https://github.com/Jovian-Experiments/steamos-customizations-jupiter/blob/jupiter-20241107.1/misc/modules-load.d/hid-preload.conf
      boot.kernelModules = [
        "hid_nintendo"
        "hid_playstation"
      ];
      # Deck specific, not needed on latest non-vendor kernels
      # 
      boot.kernelParams = [
        "fbcon=rotate:1"

        # Valve says:
        # amdgpu.sched_hw_submission is set to 4 to avoid bubbles of lack-of work
        # with the default (2).
        # 4 is the maximum that is supported across RDNA2 + RDNA3.
        # Any more results in a hang at startup on RDNA3.
        "amdgpu.sched_hw_submission=4"

        # it currently causes black/white flashes when showing/hiding planes
        # https://github.com/Jovian-Experiments/jupiter-hw-support/commit/1a2776307a58d065c619d4d7350be6d5a202e991
        "amdgpu.dcdebugmask=0x20000"

      ];

      # Ensures modules missing from the vendor kernel don't cause a generation build failure.
      jovian.workarounds.ignoreMissingKernelModules = mkDefault true;
    }
  ]);
}
