{ pkgs ? import <nixpkgs> {} }:

let
  nixos = import "${pkgs.path}/nixos";
  eval = nixos {
    configuration = {
      imports = [
        ./configuration.nix
      ];
    };
  };
in
with eval;
config.system.build.isoImage
