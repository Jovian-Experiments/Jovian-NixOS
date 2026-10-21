{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.jovian.hardware.valve;

  alsa-ucm-conf' = pkgs.runCommand "jovian-ucm-conf" { } ''
    cp -r --no-preserve=all ${pkgs.alsa-ucm-conf} $out

    # override acp5x configs with Jovian stuff
    cp -rf ${pkgs.jovianPackages.steamdeck-dsp}/share/alsa $out/share

    # remove more specific upstream symlink so Valve acp5x config is picked
    rm $out/share/alsa/ucm2/conf.d/acp5x/Valve-Jupiter-1.conf
  '';
in
{
  options = {
    jovian.hardware.valve.steamdeck-dsp.enable = lib.mkOption {
      default = cfg.enable;
      defaultText = "config.jovian.hardware.valve.enable";
      type = lib.types.bool;
      description = ''
        Whether to enable custom sound post-processing for Valve hardware.

        This is generally a no-op on non-Valve devices, but costs additional rebuilds.
      '';
    };
  };

  config =
    let
      systemWide = config.services.pipewire.systemWide;

      extraEnv.ALSA_CONFIG_UCM2 = "${alsa-ucm-conf'}/share/alsa/ucm2";
    in
    lib.mkIf cfg.steamdeck-dsp.enable {
      hardware.firmware = [
        (lib.hiPrio pkgs.jovianPackages.steamdeck-dsp)
      ];

      services.pulseaudio.enable = false;

      services.pipewire = {
        enable = true;
        package = pkgs.jovianPackages.pipewire;
        pulse.enable = true;
        alsa.enable = true;
        configPackages = [ pkgs.jovianPackages.steamdeck-dsp ];
        wireplumber.package = pkgs.jovianPackages.wireplumber;
        wireplumber.configPackages = [ pkgs.jovianPackages.steamdeck-dsp ];
      };

      environment.variables = extraEnv;

      systemd.packages = [ pkgs.jovianPackages.steamdeck-dsp ];

      systemd.services.pipewire.environment = lib.mkIf systemWide extraEnv;
      systemd.user.services.pipewire.environment = lib.mkIf (!systemWide) extraEnv;

      systemd.services.wireplumber.environment = lib.mkIf systemWide extraEnv;
      systemd.user.services.wireplumber.environment = lib.mkIf (!systemWide) extraEnv;

      systemd.services.pipewire-sysconf = {
        enable = true;
        wantedBy = [ "multi-user.target" ];
      };
      systemd.services.wireplumber-sysconf = {
        enable = true;
        wantedBy = [ "multi-user.target" ];
      };
      systemd.user.services.filter-chain = {
        enable = true;
        wantedBy = [ "default.target" ];
      };
    };
}
