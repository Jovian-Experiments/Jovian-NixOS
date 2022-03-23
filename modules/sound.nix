{ config, lib, pkgs, ... }:

{
  options = {
    jovian = {
      enableSoundSupport = lib.mkOption {
        default = true;
        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf config.jovian.enableSoundSupport {
    environment.variables.ALSA_CONFIG_UCM2 = "/run/current-system/sw/share/alsa/ucm2";
    systemd.user.services.pulseaudio.environment.ALSA_CONFIG_UCM2 = config.environment.variables.ALSA_CONFIG_UCM2;
    systemd.services.pulseaudio.environment.ALSA_CONFIG_UCM2 = config.environment.variables.ALSA_CONFIG_UCM2;

    environment.pathsToLink = [
      "share/alsa/ucm2/conf.d"
    ];

    environment.systemPackages = with pkgs; [
      alsa-lib # So it gets linked into `pathsToLink`
      acp5x-ucm
    ];
  };
}
