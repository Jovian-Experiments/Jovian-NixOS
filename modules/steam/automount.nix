{lib, config, pkgs, ...}: let
  inherit (lib) mkIf mkMerge mkOption types mdDoc mkEnableOption;
  inherit (lib.strings) concatMapStringsSep;
  inherit (pkgs) systemd util-linux procps steam writeShellScriptBin ;
  cfg = config.jovian.steam;
  mount-script = writeShellScriptBin "mount-script" ''
#Steam Deck Mount External Drive by scawp
#License: DBAD: https://github.com/scawp/Steam-Deck.Mount-External-Drive/blob/main/LICENSE.md
#Source: https://github.com/scawp/Steam-Deck.Mount-External-Drive
# Use at own Risk!

     urlencode()
     {
# From https://gist.github.com/HazCod/da9ec610c3d50ebff7dd5e7cac76de05
        [ -z "$1" ] || echo -n "$@" | ${util-linux}/bin/hexdump -v -e '/1 "%02x"' | sed 's/\(..\)/%\1/g'
     }
     mount_drive()
     {
        label="$(${util-linux}/bin/lsblk -noLABEL $1)"
        if [ -z "$label" ]; then
          label="$(${util-linux}/bin/lsblk -noUUID $1)"
        fi
        mkdir -p "/mnt/$label"
        chown ${cfg.user} -R "/mnt/$label"
        ${util-linux}/bin/mount "$1" "/mnt/$label"
        sleep 5
        mount_point="$(${util-linux}/bin/lsblk -noMOUNTPOINT $1)"
        if [ -z "$mount_point" ]; then
          echo "Failed to mount "$1" at /mnt/$label"
        else
          if [ -d "$mount_point/SteamLibrary" ]; then
            library="$mount_point/SteamLibrary"
            url=$(urlencode "''${library}")
            if ${procps}/bin/pgrep -x "steam" > /dev/null; then
              ${systemd}/bin/systemd-run -M 1000@ --user --collect --wait \
              sh -c "${steam}/bin/steam steam://addlibraryfolder/''${url}"
            fi
          else
            echo "no steam library on drive"
          fi
        fi
     }
     if [ "$1" = "remove" ]; then
        exit 0
     else
        mount_drive "/dev/$2"
     fi
     exit 0
  '';
in {
  options.jovian.steam.automount = {
    enable = mkEnableOption "Automatically mount drives and add its Steamlibrary if available.";

    user = mkOption {
      type = types.str;
      default = cfg.user;
      description = mdDoc ''
        The user steam is running with.
      '';
    };

    patterns = mkOption {
      type = types.listOf types.str;
      default = ["sd[a-z][0-9]"];
      description = mdDoc ''
        A list of glob patterns for selecting devices to automount.
      '';
    };
  };
  config = mkIf cfg.automount.enable {
    services.udev.extraRules= concatMapStringsSep "\n" (pattern: ''
        KERNEL=="${pattern}", ACTION=="add", RUN+="${systemd}/bin/systemctl start --no-block jovian-automount@%k.service"
        KERNEL=="${pattern}", ACTION=="remove", RUN+="${systemd}/bin/systemctl stop --no-block jovian-automount@%k.service"
    '') cfg.automount.patterns;

    systemd.services."jovian-automount@".serviceConfig = {
      Type = "oneshot";
      RemainAfterExit=true;
      ExecStart="${mount-script}/bin/mount-script add %i";
      ExecStop="${mount-script}/bin/mount-script remove %i";
    };
  };
}
