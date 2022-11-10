{ config, lib, pkgs, ... }:

let
  cfg = config.jovian.devices.steamdeck;
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

      # TODO: overlay on top of the vanilla alsa-lib using environment.pathsToLink
      # Currently this does not work due to some weird path concatenation behavior in alsa-lib:
      #
      #     openat(AT_FDCWD, "/run/current-system/sw/share/alsa/ucm2/conf.d/acp5x//nix/store/hxm24krvwjyys9zfirn203sf3ncm44gs-acp5x-ucm-jupiter-20220310.1000/share/alsa/ucm2/conf.d/acp5x/HiFi.conf", O_RDONLY) = -1 ENOENT (No such file or directory)
      environment.variables.ALSA_CONFIG_UCM2 = "${pkgs.jupiter-hw-support}/share/alsa/ucm2";
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
