{ lib, ... }:

let
  inherit (lib)
    mkOption
    types
  ;
in
{
  imports = [
    ./steam.nix
    ./autostart.nix
    ./environment.nix
  ];
  options = {
    jovian = {
      steam = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Whether to enable the Steam Deck UI.

            When enabled, you can either use the `autoStart` option (preferred),
            launch the Steam Deck UI from your Display Manager or
            by running `start-gamescope-session`.
          '';
        };
      };
    };
  };
}
