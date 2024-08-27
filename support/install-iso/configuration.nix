{ lib, modulesPath, pkgs, ... }:

{
  imports = [
    # we don't want to pull in Calamares, as it's not Jovian-aware
    (modulesPath + "/installer/cd-dvd/installation-cd-graphical-base.nix")
    ../../modules
  ];

  config = {
    services.desktopManager.plasma6.enable = true;

    # Automatically login as nixos.
    services.displayManager = {
      sddm.enable = true;
      autoLogin = {
        enable = true;
        user = "nixos";
      };
    };

    environment.systemPackages = [
      # FIXME: using Qt5 builds of Maliit as upstream has not ported to Qt6 yet
      pkgs.maliit-framework
      pkgs.maliit-keyboard
    ];

    jovian.devices.steamdeck.enable = true;
    hardware.pulseaudio.enable = lib.mkForce false;
  };
}
