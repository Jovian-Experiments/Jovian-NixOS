{ config, lib, pkgs, utils, ... }:

let
  cfg = config.jovian.devices.steamdeck;
in
{
  options = {
    jovian.devices.steamdeck = {
      fde = {
        deckbd = {
          enable = lib.mkOption {
            default = cfg.enable;
            defaultText = lib.literalExpression "config.jovian.devices.steamdeck.enable";
            type = lib.types.bool;
            description = ''
              Whether to enable deckbd for initrd password entry.

              You may need hold the option key for a second before entering your
              password.
            '';
          };
          bindsTo = lib.mkOption {
            inherit (utils.systemdUtils.unitOptions.commonUnitOptions.options.bindsTo) type;
            description = ''
              systemd units that require deckbd.

              For example, if you want controller input in unl0kr, add `config.boot.initrd.systemd.services.unl0kr-ask-password.name`.

              Plymouth and the console work by default.
            '';
          };
          debug = lib.mkOption {
            default = false;
            type = lib.types.bool;
            description = ''
              Enable debug output for deckbd.

              This will log keycodes to the journal.
            '';
          };
        };
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.fde.deckbd.enable {
      assertions = [
        {
          assertion = cfg.enableDefaultStage1Modules;
          message = ''
            deckbd cannot be used without the required kernel modules.

            jovian.devices.steamdeck.enableDefaultStage1Modules must be enabled.
          '';
        }
        {
          assertion = config.boot.initrd.systemd.enable;
          message = ''
            deckbd requires systemd-in-initrd.

            boot.initrd.systemd.enable must be set to true. Note that this may impact other NixOS features.
          '';
        }
      ];

      jovian.devices.steamdeck.fde.deckbd.bindsTo = [
        "systemd-ask-password-console.service"
        (lib.mkIf config.boot.plymouth.enable config.systemd.services.systemd-ask-password-plymouth.name)
        # Note: Agents that have optional keyboard input, such as unl0kr, should not be added here. The user may not want it.
      ];

      boot.initrd = {
        kernelModules = [ "uinput" ];

        services.udev.packages = [
          (pkgs.writeTextDir "lib/udev/rules.d/70-steam-deck-controller.rules" ''
            ACTION=="add", SUBSYSTEM=="input", ENV{ID_VENDOR_ID}=="28de", ENV{ID_MODEL_ID}=="1205", ENV{PRODUCT}=="?*", ENV{ID_INPUT_JOYSTICK}=="1", TAG+="systemd", ENV{SYSTEMD_ALIAS}+="/sys/class/input/input_steam_deck_controller"
          '')
        ];

        systemd = {
          storePaths = with pkgs; [ deckbd ]; # https://github.com/NixOS/nixpkgs/issues/309316
          services.deckbd = {
            description = "Steam Deck controller keymapper";
            unitConfig.DefaultDependencies = false;
            wantedBy = cfg.fde.deckbd.bindsTo;
            before = cfg.fde.deckbd.bindsTo;
            inherit (cfg.fde.deckbd) bindsTo;
            requires = [ "sys-class-input-input_steam_deck_controller.device" ];
            after = [ "sys-class-input-input_steam_deck_controller.device" ];
            path = with pkgs; [ deckbd ];
            environment.G_MESSAGES_DEBUG = lib.mkIf cfg.fde.deckbd.debug "all";
            # Note: The lizard_mode parameter does not work as intended. The
            # Steam Deck must also be manually put into gamepad mode by holding
            # the option key for a second.
            preStart = "echo 0 > /sys/module/hid_steam/parameters/lizard_mode";
            script = "deckbd";
            postStop = "echo 1 > /sys/module/hid_steam/parameters/lizard_mode";
          };
        };
      };
    })
  ];
}
