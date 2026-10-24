{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.jovian.steamos.enableVendorMesa = lib.mkOption {
    default = false;
    type = lib.types.bool;
    description = ''
      Enable SteamOS Mesa drivers. 

      These are only validated on a small subset of hardware, which is mostly handhelds,
      so enabling this on desktop systems is not recommended.
    '';
  };

  config = lib.mkIf (config.jovian.steamos.enableVendorMesa) {
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
