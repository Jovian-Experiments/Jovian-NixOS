{ lib, config, ... }:

let
  inherit (lib)
    mkOption
    types
  ;
in
{
  imports = [
    ./automount.nix
    ./bluetooth.nix
    ./boot.nix
    ./earlyoom.nix
    ./misc.nix
    ./sysctl.nix
    ./fan-control.nix
    ./controller.nix
    ./perf-control.nix
    ./rename.nix
    ./sound.nix
    ./graphics.nix
  ];
  options = {
    jovian.steamos = {
      useSteamOSConfig = mkOption {
        type = types.bool;
        default = config.jovian.steam.enable;
        defaultText = "config.jovian.steam.enable";
        description = ''
          Whether to enable opinionated system configuration from SteamOS.

          When true, this will enable most options under the `jovian.steamos` namespace.
        '';
      };
    };
  };
}
