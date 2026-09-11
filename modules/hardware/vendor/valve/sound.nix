{ config, lib, pkgs, ... }:

let
  cfg = config.jovian.hardware.vendor.valve;


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
    jovian.hardware.vendor.valve = {
      enableSoundSupport = lib.mkOption {
        default = cfg.enable;
        defaultText = lib.literalExpression "config.jovian.hardware.vendor.valve.enable";
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
  in lib.mkIf cfg.enable {
    services.pulseaudio.enable = false;

    services.pipewire = {
      enable = true;
      package = pkgs.pipewire-jupiter;
      pulse.enable = true;
      alsa.enable = true;
      configPackages = [ pkgs.steamdeck-dsp ];
      wireplumber.package = pkgs.wireplumber-jupiter;
      wireplumber.configPackages = [ pkgs.steamdeck-dsp ];
    };

    environment.variables = extraEnv;

    systemd.packages = [ pkgs.steamdeck-dsp ];

    systemd.services.pipewire.environment = lib.mkIf systemWide extraEnv;
    systemd.user.services.pipewire.environment = lib.mkIf (!systemWide) extraEnv;

    systemd.services.wireplumber.environment = lib.mkIf systemWide extraEnv;
    systemd.user.services.wireplumber.environment = lib.mkIf (!systemWide) extraEnv;

    systemd.services.pipewire-sysconf = {
      enable = true;
      wantedBy = ["multi-user.target"];
    };
    systemd.services.wireplumber-sysconf = {
      enable = true;
      wantedBy = ["multi-user.target"];
    };
    systemd.user.services.filter-chain = {
      enable = true;
      wantedBy = ["default.target"];
    };
  };
}
