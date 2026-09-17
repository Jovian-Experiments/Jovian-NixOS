# BIOS updates
{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkIf
    mkMerge
    mkOption
    types
  ;
  cfg = config.jovian.devices.steammachine;
in
{
  options = {
    jovian.devices.steammachine = {
      enableFwupdBiosUpdates = mkOption {
        type = types.bool;
        default = cfg.enable;
        defaultText = lib.literalExpression "config.jovian.devices.steammachine.enable";
        description = ''
          Whether to use fwupd to update the BIOS.
        '';
      };
      autoUpdate = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to automatically update the System BIOS.
        '';
      };
    };
  };

  config = mkMerge [
    (mkIf (cfg.enable) {
      hardware.firmware = [
        (lib.hiPrio pkgs.linux-firmware-jupiter)
      ];
    })
    (mkIf (cfg.enableFwupdBiosUpdates) {
      services.fwupd.enable = true;

      environment.etc."fwupd/remotes.d/fremont-vendor-directory.conf".text = ''
        # Enabled by jovian.devices.steammachine.enableFwupdBiosUpdates

        [fwupd Remote]
        Enabled=true
        Title=Fremont HW Support Updates
        Keyring=none
        MetadataURI=file://${pkgs.fremont-hw-support}/share/fwupd/remotes.d/fremont/firmware
        ApprovalRequired=false
      '';
    })
    (mkIf (cfg.autoUpdate) {
      systemd.services.fremont-firmware-update = {
        description = "Steam Machine firmware auto-update";
        before = [ "display-manager.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${config.services.fwupd.package}/bin/fwupdmgr update --assume-yes 47b13de8-b6ee-4a22-bcd3-7fe5e1a660de";
        };
      };
    })
  ];
}
