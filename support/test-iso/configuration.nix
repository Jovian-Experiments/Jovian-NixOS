{ config, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/cd-dvd/iso-image.nix")
    (modulesPath + "/profiles/all-hardware.nix")
    ./jovian.nix
    ./tty.nix
    ./user.nix
  ];

  config = {
    isoImage.isoBaseName = "Jovian-NixOS-FOR-TESTING-ONLY";
    isoImage.makeEfiBootable = true;
    isoImage.makeUsbBootable = true;
    isoImage.squashfsCompression = "zstd -Xcompression-level 15";
    isoImage.isoName = "${config.isoImage.isoBaseName}-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.iso";

    hardware.enableRedistributableFirmware = true;
    nixpkgs.config.allowUnfree = true;

    # NOTE: this is an insecure system, but it's also FOR TESTING ONLY.
    services.openssh.enable = true;
  };
}
