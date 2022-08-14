# Steam Deck-specific configurations
#
# jovian.devices.steamdeck

{ config, lib, ... }:

let
  inherit (lib)
    mkOption
    types
  ;
in
{
  imports = [
    ./controller.nix
    ./fan-control.nix
    ./graphical.nix
    ./hw-support.nix
    ./kernel.nix
    ./mesa.nix
    ./perf-control.nix
    ./sdgyrodsu.nix
    ./sound.nix
  ];

  options = {
    jovian.devices.steamdeck = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable Steam Deck-specific configurations.
        '';
      };
    };
  };
}
