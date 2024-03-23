{ config, lib, pkgs, ... }:

let
  cfg = config.jovian.devices.steamdeck;

  alsa-ucm-conf' = pkgs.runCommand "jovian-ucm-conf" {} ''
    cp -r --no-preserve=all ${pkgs.alsa-ucm-conf} $out

    # override acp5x configs with Jovian stuff
    cp -rf ${pkgs.steamdeck-dsp}/share/alsa $out/share
    
    # remove more specific upstream symlink so Valve acp5x config is picked
    rm $out/share/alsa/ucm2/conf.d/acp5x/Valve-Jupiter-1.conf
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

  config = let
    systemWide = config.services.pipewire.systemWide;

    extraEnv.ALSA_CONFIG_UCM2 = "${alsa-ucm-conf'}/share/alsa/ucm2";
  in lib.mkIf cfg.enableSoundSupport {
    hardware.pulseaudio.enable = false;

    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      configPackages = [ pkgs.steamdeck-dsp ];
      wireplumber = {
        package = pkgs.wireplumber-jovian;
        configPackages = [ pkgs.steamdeck-dsp ];
      };
    };

    environment.variables = extraEnv;

    systemd.packages = [ pkgs.steamdeck-dsp ];

    systemd.services.pipewire.environment = lib.mkIf systemWide extraEnv;
    systemd.user.services.pipewire.environment = lib.mkIf (!systemWide) extraEnv;

    systemd.services.wireplumber.environment = lib.mkIf systemWide extraEnv;
    systemd.user.services.wireplumber.environment = lib.mkIf (!systemWide) extraEnv;

    systemd.services.wireplumber-sysconf = {
      wantedBy = ["multi-user.target"];
      before = ["display-manager.service"];
    };
  };
}
