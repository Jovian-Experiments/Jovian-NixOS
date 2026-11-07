{
  config,
  lib,
  pkgs,
  ...
}:

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
      package = pkgs.jovianPackages.mesa-radeonsi;
      package32 = pkgs.pkgsi686Linux.jovianPackages.mesa-radeonsi;
      extraPackages = [ (lib.hiPrio pkgs.jovianPackages.mesa-radv) ];
      extraPackages32 = [ (lib.hiPrio pkgs.pkgsi686Linux.jovianPackages.mesa-radv) ];
    };

    environment.etc."drirc".source =
      pkgs.jovianPackages.mesa-radv + "/share/drirc.d/00-radv-defaults.conf";
  };
}
