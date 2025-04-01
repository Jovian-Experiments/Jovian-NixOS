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
    services.pulseaudio.enable = false;

    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      configPackages = [ pkgs.steamdeck-dsp ];
      wireplumber.package = pkgs.wireplumber-jupiter;
      wireplumber.configPackages = [ pkgs.steamdeck-dsp ];
    };

    environment.variables = extraEnv;

    systemd.services.pipewire.environment = lib.mkIf systemWide extraEnv;
    systemd.user.services.pipewire.environment = lib.mkIf (!systemWide) extraEnv;

    systemd.services.wireplumber.environment = lib.mkIf systemWide extraEnv;
    systemd.user.services.wireplumber.environment = lib.mkIf (!systemWide) extraEnv;

    # These are copied from upstream steamdeck-dsp because upstream
    # has terrible systemd ordering.
    systemd.services.pipewire-sysconf = {
      description = "Hardware Specific Pipewire Configuration";
      unitConfig.ConditionPathIsDirectory = "/run";
      before = ["multi-user.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.steamdeck-dsp}/share/pipewire/hardware-profiles/pipewire-hwconfig";
      };
    };
    systemd.services.wireplumber-sysconf = {
      description = "Hardware Specific Wireplumber Configuration";
      unitConfig.ConditionPathIsDirectory = "/run";
      before = ["multi-user.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.steamdeck-dsp}/share/wireplumber/hardware-profiles/wireplumber-hwconfig";
      };
    };
  };
}
