{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkDefault
    mkIf
    mkOption
    types
  ;
  cfg = config.jovian.devices.steammachine;
in
{
  options = {
    jovian.devices.steammachine = {
      enableVendorKernel = mkOption {
        type = types.bool;
        default = cfg.enable;
        defaultText = lib.literalExpression "config.jovian.devices.steammachine.enable";
        description = ''
          Whether to use Valve's SteamOS kernel.
        '';
      };
    };
  };

  config = mkIf (cfg.enableVendorKernel) {
    boot.kernelPackages = mkDefault pkgs.linuxPackages_jovian;
  };
}
