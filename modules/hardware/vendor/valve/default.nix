{ config, lib, ...}:

let
  inherit (lib)
    mkIf
    mkOption
    types
  ;

    cfg_deck = config.jovian.devices.steamdeck;
    cfg_machine = config.jovian.devices.steammachine;
in
{
  imports = [
    ./controller.nix
    ./perf-control.nix
    ./sound.nix
    ./rename.nix
  ];

  options = {
    jovian.hardware.vendor.valve = {
      enable = mkOption {
        type = types.bool;
        default = (cfg_deck.enable || cfg_machine.enable );
        defaultText = lib.literalExpression "config.jovian.devices.steamdeck.enable || config.jovian.devices.steammachine.enable";
        description = ''
          Whether to enable vendor specific configurations common for all Valve Hardware
        '';
      };
    };
  };
}
