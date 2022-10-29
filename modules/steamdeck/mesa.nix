{ config, lib, pkgs, ... }:

let
  inherit (lib) types;

  cfg = config.jovian.devices.steamdeck;

  mesaVersion = pkgs.mesa.version;
  hasMesaPatches = lib.hasPrefix "22.2." mesaVersion;
  patchMesa = mesa: mesa.overrideAttrs (old: {
    patches = (old.patches or []) ++ [
      (pkgs.fetchpatch {
        url = "https://github.com/Mesa3D/mesa/compare/mesa-22.2.0...Jovian-Experiments:mesa:radeonsi-3.4.0.diff";
        hash = "sha256-civjqKlTiVjcb/MI5v9AEon52YSvw7iDRLm1tji9pKo=";
      })
    ];
  });
in
{
  options = {
    jovian.devices.steamdeck = {
      enableVendorRadv = lib.mkOption {
        type = types.bool;
        default = cfg.enable;
        description = ''
          Whether to enable the vendor branch of Mesa RADV.
        '';
      };
      enableMesaPatches = lib.mkOption {
        type = types.bool;
        default = cfg.enable;
        description = ''
          Whether to apply the Mesa patches if available.

          Currently, they allow the swapchain interval to be changed by
          the framerate limiter in gamescope.
        '';
      };
      hasMesaPatches = lib.mkOption {
        type = types.bool;
        internal = true;
        default = false;
        description = ''
          Interface between modules to describe whether Mesa patches are available.
        '';
      };
    };
  };

  config = lib.mkMerge [
    # Mesa gamescope patches
    {
      jovian.devices.steamdeck.hasMesaPatches = hasMesaPatches;
    }
    (lib.mkIf (cfg.enableMesaPatches && cfg.hasMesaPatches) {
      hardware.opengl.package = (patchMesa pkgs.mesa).drivers;
      hardware.opengl.package32 = (patchMesa pkgs.pkgsi686Linux.mesa).drivers;
    })
    (lib.mkIf (cfg.enableMesaPatches && !cfg.hasMesaPatches) {
      warnings = [
        ''
          Mesa patches for improved gamescope integration missing for Mesa version "${mesaVersion}"
        ''
      ];
    })

    # Jupiter RADV
    (lib.mkIf (cfg.enableVendorRadv) {
      hardware.opengl = {
        extraPackages = [ pkgs.mesa-radv-jupiter.drivers ];
        extraPackages32 = [ pkgs.pkgsi686Linux.mesa-radv-jupiter.drivers ];
      };

      environment.etc."drirc".source = pkgs.mesa-radv-jupiter + "/share/drirc.d/00-radv-defaults.conf";
    })
  ];
}
