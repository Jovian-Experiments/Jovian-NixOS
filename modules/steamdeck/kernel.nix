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

  kernelBranch = config.boot.kernelPackages.kernel.meta.branch;

  # FIXME: Stop hardcoding patch to 5.13
  # TODO: Make an attrset of kernel major versions with the appropriate patches.
  hasKernelPatches = kernelBranch == "5.13";
  orientationQuirk = {
    name = "Steam Deck orientation quirk";
    patch = ../../patches/kernel/5.13/0001-drm-Added-orientation-quirk-for-Valve-Steam-Deck.patch;
  };
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
      hasKernelPatches = mkOption {
        type = types.bool;
        internal = true;
        default = false;
        description = ''
          Interface between modules to describe whether kernel patches are available
        '';
      };
    };
  };
  config = mkIf (cfg.enableKernelPatches) (mkMerge [
    {
      boot.kernelPackages = mkDefault pkgs.linuxPackages_jovian;
      jovian.devices.steamdeck.hasKernelPatches = hasKernelPatches;
    }
    (mkIf (cfg.hasKernelPatches) {
      boot.kernelPatches = [
        orientationQuirk
      ];
    })
    (mkIf (!cfg.hasKernelPatches) {
      warnings = [
        ''
          Kernel patches for improved default hardware support missing for kernel branch "${kernelBranch}".
        ''
      ];
    })
  ]);
}
