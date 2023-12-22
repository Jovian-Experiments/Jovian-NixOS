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
    }
    {
      # Enable MTU probing, as vendor does
      # See: https://github.com/ValveSoftware/SteamOS/issues/1006
      # See also: https://www.reddit.com/r/SteamDeck/comments/ymqvbz/ubisoft_connect_connection_lost_stuck/j36kk4w/?context=3
      boot.kernel.sysctl."net.ipv4.tcp_mtu_probing" = true;

      hardware.opengl = {
        driSupport32Bit = true;
        extraPackages = [ pkgs.gamescope.lib ];
        extraPackages32 = [ (pkgs.pkgsi686Linux.gamescope.overrideAttrs(old: {
          mesonFlags = old.mesonFlags or [] ++ ["-Denable_gamescope=false"];
          postInstall = null;
        })).lib ];
      };

      hardware.pulseaudio.support32Bit = true;
      hardware.steam-hardware.enable = mkDefault true;

      environment.systemPackages = [ pkgs.gamescope-session pkgs.steamos-polkit-helpers ];

      systemd.packages = [ pkgs.gamescope-session ];

      services.xserver.displayManager.sessionPackages = [ pkgs.gamescope-session ];

      # Conflicts with power-button-handler
      services.logind.extraConfig = ''
        HandlePowerKey=ignore
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
    }
  ]);
}
