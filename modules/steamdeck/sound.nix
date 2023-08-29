{ config, lib, pkgs, ... }:

let
  cfg = config.jovian.devices.steamdeck;

  alsa-ucm-conf' = pkgs.runCommand "jovian-ucm-conf" {} ''
    cp -r --no-preserve=all ${pkgs.alsa-ucm-conf} $out

    # override acp5x configs with Jovian stuff
    cp -f ${pkgs.jupiter-hw-support}/share/alsa/ucm2/conf.d/acp5x/* $out/share/alsa/ucm2/conf.d/acp5x/
  '';
in
{
  options = {
    jovian.devices.steamdeck = {
      enableSoundSupport = lib.mkOption {
        default = cfg.enable;
        defaultText = lib.literalExpression "config.jovian.devices.steamdeck.enable";
        type = lib.types.bool;
        description = ''
          Whether to enable sound support.
        '';
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

      environment.variables.ALSA_CONFIG_UCM2 = "${alsa-ucm-conf'}/share/alsa/ucm2";
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
    in {
      systemd.services.pipewire = lib.mkIf systemWide {
        environment.ALSA_CONFIG_UCM2 = config.environment.variables.ALSA_CONFIG_UCM2;
      };
      systemd.user.services.pipewire = lib.mkIf (!systemWide) {
        environment.ALSA_CONFIG_UCM2 = config.environment.variables.ALSA_CONFIG_UCM2;
      };
    }))
  ]);
}
