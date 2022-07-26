{ config, lib, pkgs, ... }:
let
  cfg = config.jovian.workarounds;
in
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
    nixpkgs.overlays = lib.mkIf (cfg.ignoreMissingKernelModules) [
      (final: super: {
        # Workaround for modules expected by NixOS not being built
        # (vmw_balloon, among most likely other)
        makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
      })
    ];
  };
}

