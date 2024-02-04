{ lib, ... }:

let
  inherit (lib)
    mkOption
    types
  ;
in
{
  imports = [
    ./bluetooth.nix
    ./boot.nix
    ./mesa.nix
    ./misc.nix
    ./sysctl.nix
  ];
  options = {
    jovian.steamos = {
      useSteamOSConfig = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to enable opinionated system configuration from SteamOS.

          When true, this will enable most options under the `jovian.steamos` namespace.
        '';
      };
    };
  };
}
