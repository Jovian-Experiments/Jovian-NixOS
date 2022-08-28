{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkDefault
    mkIf
    mkMerge
    mkOption
    types
  ;
in
{
  options = {
    jovian = {
      steam = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Whether to enable the Steam Deck UI.

            When enabled, you can either launch the Steam Deck UI
            from your Display Manager or by running `steam-session`.
          '';
        };
      };
    };
  };
  config = mkMerge [
    (mkIf config.jovian.steam.enable {
      hardware.opengl.driSupport32Bit = true;
      hardware.pulseaudio.support32Bit = true;

      environment.systemPackages = [ pkgs.steam-session ];

      services.xserver.displayManager.sessionPackages = [ pkgs.steam-session ];

      # Conflicts with power-button-handler
      services.logind.extraConfig = ''
        HandlePowerKey=ignore
      '';
    })
  ];
}
