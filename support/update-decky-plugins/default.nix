{ pkgs, ...}: let
 hpkgs = pkgs.haskell.packages.ghc94; 
in hpkgs.callCabal2nix "update-decky-plugins" ./. { } 
