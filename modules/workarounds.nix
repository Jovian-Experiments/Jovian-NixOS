{ config, lib, pkgs, ... }:

{
  options = {
    jovian = {
      workarounds = {
        ignoreMissingKernelModules = lib.mkOption {
          default = true;
          type = lib.types.bool;
        };
      };
    };
  };

  config = {
    nixpkgs.overlays = lib.mkIf (config.jovian.workarounds.ignoreMissingKernelModules) [
      (final: super: {
        # Workaround for modules expected by NixOS not being built
        # (vmw_balloon, among most likely other)
        makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
      })
    ];
  };
}

