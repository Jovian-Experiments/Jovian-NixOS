{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkIf
    mkOption
    types
    ;
  cfg = config.jovian.steamos;
in
{
  options = {
    jovian.steamos = {
      enableVendorDrivers = mkOption {
        default = cfg.useSteamOSConfig;
        defaultText = lib.literalExpression "config.jovian.steamos.useSteamOSConfig";
        type = types.bool;
        description = ''
          Whether to use Valve's branches of drivers instead of upstream Mesa.

          These drivers may include additional fixes, but are not validated
          on non-Valve hardware.
        '';
      };
    };
  };

  config = mkIf cfg.enableVendorDrivers {
    hardware.graphics = {
      package = pkgs.mesa-radeonsi-jupiter;
      package32 = pkgs.pkgsi686Linux.mesa-radeonsi-jupiter;
      extraPackages = [ (lib.hiPrio pkgs.mesa-radv-jupiter) ];
      extraPackages32 = [ (lib.hiPrio pkgs.pkgsi686Linux.mesa-radv-jupiter) ];
    };

    environment.etc."drirc".source = pkgs.mesa-radv-jupiter + "/share/drirc.d/00-radv-defaults.conf";
  };
}
