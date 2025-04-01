{ pkgs, ...}: let
 hpkgs = pkgs.haskell.packages.ghc96; 
in hpkgs.callCabal2nix "update-decky-plugins" ./. { } 
