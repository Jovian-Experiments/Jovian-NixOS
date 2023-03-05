{ config, lib, pkgs, ... }:

let
  cfg = config.jovian.devices.steamdeck;

  alsa-ucm-conf' = pkgs.alsa-ucm-conf.overrideAttrs (prev: {
    # This dumb import breaks all the audio on the Deck itself.
    # Best sources as to why I could find:
    # https://github.com/alsa-project/alsa-ucm-conf/issues/104
    # see comments: https://github.com/alsa-project/alsa-ucm-conf/commit/1e6297b650114cb2e043be4c677118f971e31eb7
    postInstall = ''
      ${pkgs.gnused}/bin/sed -i /Include.libgen.File/d $out/share/alsa/ucm2/ucm.conf
    '';
    meta.priority = -10;
  });
in
{
  options = {
    jovian.devices.steamdeck = {
      enableSoundSupport = lib.mkOption {
        default = cfg.enable;
        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf (cfg.enableSoundSupport) (lib.mkMerge [
    {
      hardware.pulseaudio.enable = lib.mkDefault false;

      services.pipewire = {
        enable = lib.mkDefault true;
        pulse.enable = lib.mkDefault true;
        alsa.enable = lib.mkDefault true;
      };

      environment = {
        pathsToLink = [ "share/alsa/ucm2" ];
        variables.ALSA_CONFIG_UCM2 = "/run/current-system/sw/share/alsa/ucm2";
        systemPackages = [ pkgs.jupiter-hw-support alsa-ucm-conf' ];
      };
    }

    # Pulseaudio
    (lib.mkIf (config.hardware.pulseaudio.enable) (let
      systemWide = config.hardware.pulseaudio.systemWide;
    in {
      systemd.services.pulseaudio = lib.mkIf systemWide {
        environment.ALSA_CONFIG_UCM2 = config.environment.variables.ALSA_CONFIG_UCM2;
      };
      systemd.user.services.pulseaudio = lib.mkIf (!systemWide) {
        environment.ALSA_CONFIG_UCM2 = config.environment.variables.ALSA_CONFIG_UCM2;
      };
    }))

    # Pipewire
    (lib.mkIf (config.services.pipewire.enable) (let
      systemWide = config.services.pipewire.systemWide;
      sessionManager =
        if config.services.pipewire.wireplumber.enable then "wireplumber"
        else if config.services.pipewire.media-session.enable then "pipewire-media-session"
        else throw "Either wireplumber or pipewire-media-session must be enabled"; # unreachable
    in {
      systemd.services.${sessionManager} = lib.mkIf systemWide {
        environment.ALSA_CONFIG_UCM2 = config.environment.variables.ALSA_CONFIG_UCM2;
      };
      systemd.user.services.${sessionManager} = lib.mkIf (!systemWide) {
        environment.ALSA_CONFIG_UCM2 = config.environment.variables.ALSA_CONFIG_UCM2;
      };
    }))
  ]);
}
