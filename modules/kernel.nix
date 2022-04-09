{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkDefault
    mkIf
    mkMerge
    mkOption
    types
  ;

  kernelBranch = config.boot.kernelPackages.kernel.meta.branch;

  # FIXME: Stop hardcoding patch to 5.13
  # TODO: Make an attrset of kernel major versions with the appropriate patches.
  hasKernelPatches = kernelBranch == "5.13";
  orientationQuirk = {
    name = "Steam Deck orientation quirk";
    patch = ../patches/kernel/5.13/0001-drm-Added-orientation-quirk-for-Valve-Steam-Deck.patch;
  };
in
{
  options = {
    jovian = {
      hasKernelPatches = mkOption {
        type = types.bool;
        internal = true;
        description = ''
          Interface between modules to describe whether kernel patches are available
        '';
      };
    };
  };
  config = mkMerge [
    {
      boot.kernelPackages = mkDefault pkgs.linuxPackages_jovian;
      jovian.hasKernelPatches = hasKernelPatches;
    }
    (mkIf hasKernelPatches {
      boot.kernelPatches = [
        orientationQuirk
      ];
    })
    (mkIf (!hasKernelPatches) {
      warnings = [
        ''
          Kernel patches for improved default hardware support missing for kernel branch "${kernelBranch}".
        ''
      ];
    })
  ];
}
