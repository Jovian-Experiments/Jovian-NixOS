{ pkgs ? import ./nixpkgs.nix {} }:

let
  nixpkgsPath = pkgs.path;
  fromPkgs = path: pkgs.path + "/${path}";
  evalConfig = import (fromPkgs "nixos/lib/eval-config.nix");
  buildConfig = { configuration ? {} }:
    evalConfig {
      specialArgs = {
        inherit nixpkgsPath;
      };
      modules= [
        ./modules
        configuration
        {
          jovian.devices.steamdeck.enable = true;
        }
      ];
    }
  ;
  eval = buildConfig { };
in
{
  isoMinimal = (buildConfig {
    configuration = (fromPkgs "nixos/modules/installer/cd-dvd/installation-cd-minimal.nix");
  }).config.system.build.isoImage;
  isoGnome = (buildConfig {
    configuration = (fromPkgs "nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix");
  }).config.system.build.isoImage;
  isoPlasma = (buildConfig {
    configuration = (fromPkgs "nixos/modules/installer/cd-dvd/installation-cd-graphical-plasma5.nix");
  }).config.system.build.isoImage;
  inherit (eval) pkgs;
}
