{ config, lib, pkgs, ... }:

let
  inherit (lib) types;

  cfg = config.jovian.devices.steamdeck;

  #
  # NOTE: to test the patch works, you can `strace` something using mesa.
  # It will need to know about a limiter file path though. A bogus path is fine.
  #
  # ```
  #  $ GAMESCOPE_LIMITER_FILE=/limiter/is/working strace -P /limiter/is/working glxgears
  # openat(AT_FDCWD, "/gamescope/is/working", O_RDONLY) = -1 ENOENT (No such file or directory)
  # ```
  #
  # By using `-P` we can limit the logs to access to that (bogus) path only.
  #
  mesaPatches = {
    "22.2" = [
      (pkgs.fetchpatch {
        url = "https://github.com/Mesa3D/mesa/compare/mesa-22.2.0...Jovian-Experiments:mesa:radeonsi-3.4.0.diff";
        hash = "sha256-civjqKlTiVjcb/MI5v9AEon52YSvw7iDRLm1tji9pKo=";
      })
    ];
    "22.3" = [
      (pkgs.fetchpatch {
        url = "https://github.com/Jovian-Experiments/mesa/commit/787d60ad89a733157919366e8ecaee9aa1d5d554.patch";
        hash = "sha256-zjb9DAAC+Qg+CeSkdcjgSarHeUJwuArHL/VMy+Fik6g=";
      })
    ];
    "23.0" = [
      (pkgs.fetchpatch {
        url = "https://github.com/Jovian-Experiments/mesa/commit/de07ed63dc9e41f3ab5a3324f7cca712107ee6a5.patch";
        hash = "sha256-X+Lvl35DOyT+nGurqmi8zYOPAzP+zZsvDV6CyNqh8Os=";
      })
    ];
  };
  mesaBranchOf = mesa: lib.versions.majorMinor mesa.version;
  patchMesa = mesa: mesa.overrideAttrs (old: {
    patches = (old.patches or []) ++ mesaPatches.${mesaBranchOf mesa};
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
      jovian.devices.steamdeck.hasMesaPatches = lib.hasAttr (mesaBranchOf pkgs.mesa) mesaPatches;
    }
    (lib.mkIf (cfg.enableMesaPatches && cfg.hasMesaPatches) {
      hardware.opengl.package = (patchMesa pkgs.mesa).drivers;
      hardware.opengl.package32 = (patchMesa pkgs.pkgsi686Linux.mesa).drivers;
    })
    (lib.mkIf (cfg.enableMesaPatches && !cfg.hasMesaPatches) {
      warnings = [
        ''
          Mesa patches for improved gamescope integration missing for Mesa version "${pkgs.mesa.version}"
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
