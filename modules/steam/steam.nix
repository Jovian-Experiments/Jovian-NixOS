{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkDefault
    mkIf
    mkMerge
  ;

  cfg = config.jovian.steam;
in
{
  config = mkIf cfg.enable (mkMerge [
    {
      warnings = []
        ++ lib.optional (!config.networking.networkmanager.enable)
          "The Steam Deck UI integrates with NetworkManager (networking.networkmanager.enable) which is not enabled. NetworkManager is required to complete the first-time setup process.";
    }
    {
      security.wrappers.gamescope = {
        owner = "root";
        group = "root";
        source = "${pkgs.gamescope}/bin/gamescope";
        capabilities = "cap_sys_nice+pie";
      };

      security.wrappers.galileo-mura-extractor = {
        owner = "root";
        group = "root";
        source = "${pkgs.galileo-mura}/bin/galileo-mura-extractor";
        setuid = true;
      };
    }
    {
      # Enable the usual desktop Steam stuff
      programs.steam.enable = mkDefault true;

      boot.kernelModules = [ "ntsync" ];

      # Enable MTU probing, as vendor does
      # See: https://github.com/ValveSoftware/SteamOS/issues/1006
      # See also: https://www.reddit.com/r/SteamDeck/comments/ymqvbz/ubisoft_connect_connection_lost_stuck/j36kk4w/?context=3
      boot.kernel.sysctl."net.ipv4.tcp_mtu_probing" = true;

      hardware.graphics = {
        enable32Bit = true;
        extraPackages = [ pkgs.gamescope-wsi ];
        extraPackages32 = [ pkgs.pkgsi686Linux.gamescope-wsi ];
      };

      services.pulseaudio.support32Bit = true;
      hardware.steam-hardware.enable = mkDefault true;

      environment.systemPackages = [
        pkgs.gamescope
        pkgs.gamescope-session
        pkgs.holo-polkit-helpers
        pkgs.steamos-manager
      ];

      systemd.packages = [
        pkgs.dmemcg-booster
        pkgs.gamescope-session
        pkgs.powerbuttond
        pkgs.steamos-manager
        pkgs.vpower
      ];

      # Required by steamos-manager
      services.inputplumber.enable = true;
      services.scx = {
        enable = lib.mkDefault true;
        scheduler = "scx_lavd";
      };
      systemd.services.scx.wantedBy = lib.mkForce [];
      services.orca.enable = lib.mkDefault true;

      # https://github.com/Jovian-Experiments/steamos-manager/blob/5fecc6bbb47719a65d0b10aacbd0ffe873fb1e43/data/user/orca.service#L9
      systemd.user.services.orca.serviceConfig.EnvironmentFile = "%t/gamescope-environment";

      systemd.user.services.steamos-manager = {
        overrideStrategy = "asDropin";
        wantedBy = [ "gamescope-session.service" ];
      };

      systemd.user.services.steamos-powerbuttond = {
        overrideStrategy = "asDropin";
        wantedBy = [ "gamescope-session.service" ];
      };

      systemd.services.steamos-manager = {
        overrideStrategy = "asDropin";
        # FIXME: should probably be done upstream
        after = [ "inputplumber.service" ];
        path = [
          # .../lib/hwsupport/format-device.sh makes an unqualified `umount` call.
          "/run/wrappers/"
        ];

        # https://gitlab.steamos.cloud/holo/steamos-manager/-/issues/1
        wantedBy = [ "multi-user.target" ];
      };

      systemd.services.dmemcg-booster-system = {
        overrideStrategy = "asDropin";
        wantedBy = [ "multi-user.target" ];
      };

      systemd.user.services.dmemcg-booster-user = {
        overrideStrategy = "asDropin";
        wantedBy = [ "graphical-session-pre.target" ];
      };

      systemd.services.vpower = {
        overrideStrategy = "asDropin";
        wantedBy = [ "graphical.target" ];
      };

      services.dbus.packages = [ pkgs.steamos-manager ];

      services.displayManager.sessionPackages = [ pkgs.gamescope-session ];

      # Conflicts with powerbuttond
      services.logind.settings.Login = {
        HandlePowerKey = "ignore";
      };

      services.udev.packages = [
        pkgs.powerbuttond
      ];

      # From steam-jupiter
      # FIXME: investigate LED stuff
      services.udev.extraRules = ''
        # USB devices and topological children
        SUBSYSTEMS=="usb", TAG+="uaccess"

        # HID devices over hidraw
        KERNEL=="hidraw*", TAG+="uaccess"

        # Steam Controller udev write access
        KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess", OPTIONS+="static_node=uinput"
      '';

      # This rule allows the user to configure Wi-Fi in Deck UI.
      #
      # Steam modifies the system network configs via
      # `org.freedesktop.NetworkManager.settings.modify.system`,
      # which normally requires being in the `networkmanager` group.
      security.polkit.extraConfig = ''
        // Jovian-NixOS/steam: Allow users to configure Wi-Fi in Deck UI
        polkit.addRule(function(action, subject) {
          if (
            action.id.indexOf("org.freedesktop.NetworkManager") == 0 &&
            subject.isInGroup("users") &&
            subject.local &&
            subject.active
          ) {
            return polkit.Result.YES;
          }
        });
      '';

      jovian.steam.environment = {
        # We don't support adopting a drive, yet.
        STEAM_ALLOW_DRIVE_ADOPT = mkDefault "0";
        # Ejecting doesn't work, either.
        STEAM_ALLOW_DRIVE_UNMOUNT = mkDefault "1";
      };
    }
  ]);
}
