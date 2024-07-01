{ config, lib, pkgs, ... }:

let
  inherit (lib) types;

  cfg = config.jovian.steamos;

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
in
{
  options = {
    jovian.steamos = {
      enableVendorRadv = lib.mkOption {
        type = types.bool;
        default = cfg.useSteamOSConfig && config.jovian.hardware.has.amd.gpu;
        defaultText = lib.literalExpression "config.jovian.steamos.useSteamOSConfig && config.jovian.hardware.has.amd.gpu";
        description = ''
          Whether to enable the vendor branch of Mesa RADV.
        '';
      };
      enableMesaPatches = lib.mkOption {
        type = types.bool;
        default = cfg.useSteamOSConfig;
        defaultText = lib.literalExpression "config.jovian.steamos.useSteamOSConfig";
        description = ''
          Whether to apply the Mesa patches if available.

          Currently, they allow the swapchain interval to be changed by
          the framerate limiter in gamescope.
        '';
      };
    };
  };

  config = lib.mkMerge [
    # Jupiter Gamescope + radeonsi patches
    (lib.mkIf (cfg.enableMesaPatches) {
      hardware.graphics.package = pkgs.mesa-radeonsi-jupiter.drivers;
      hardware.graphics.package32 = pkgs.pkgsi686Linux.mesa-radeonsi-jupiter.drivers;
    })

    # Jupiter RADV
    (lib.mkIf (cfg.enableVendorRadv) {
      hardware.graphics = {
        extraPackages = [ (lib.hiPrio pkgs.mesa-radv-jupiter) ];
        extraPackages32 = [ (lib.hiPrio pkgs.pkgsi686Linux.mesa-radv-jupiter) ];
      };

      environment.etc."drirc".source = pkgs.mesa-radv-jupiter + "/share/drirc.d/00-radv-defaults.conf";
    })
  ];
}
