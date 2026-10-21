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
    ./firmware.nix
    ./hw-support.nix
    ./sdgyrodsu.nix
    ./workarounds.nix
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
    jovian.hardware = {
      has.amd.gpu = true;
      valve.enable = true;
    };

    # udev rules required for integrated controller to work
    hardware.steam-hardware.enable = true;
  };
}
