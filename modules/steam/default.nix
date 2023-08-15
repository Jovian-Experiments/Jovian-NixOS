{ config, lib, pkgs, ... }:

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
  ];
  options = {
    jovian = {
      steam = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = lib.mdDoc ''
            Whether to enable the Steam Deck UI.

            When enabled, you can either use the `autoStart` option (preferred),
            launch the Steam Deck UI from your Display Manager or
            by running `steam-session`.
          '';
        };
      };
    };
  };
}
