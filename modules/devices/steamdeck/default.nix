# Steam Deck-specific configurations
#
# jovian.devices.steamdeck

{ config, lib, ... }:

let
  inherit (lib)
    mkIf
    mkOption
    types
  ;
  cfg = config.jovian.devices.steamdeck;
in
{
  imports = [
    ./controller.nix
    ./fan-control.nix
    ./firmware.nix
    ./graphical.nix
    ./hw-support.nix
    ./kernel.nix
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
  config = mkIf cfg.enable {
    jovian.hardware.has = {
      amd.gpu = true;
    };
  };
}
