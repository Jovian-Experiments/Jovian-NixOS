{ pkgs ? import ./nixpkgs.nix {} }:

let
  nixpkgsPath = pkgs.path;
  fromPkgs = path: pkgs.path + "/${path}";
  evalConfig = import (fromPkgs "nixos/lib/eval-config.nix");
  buildConfig = { configuration ? {} }:
    evalConfig {
      specialArgs = { inherit nixpkgsPath; };
      modules= [
        ./modules
        configuration
      ];
    }
  ;
  eval = buildConfig { };
in
{
  inherit (eval) pkgs;
}
