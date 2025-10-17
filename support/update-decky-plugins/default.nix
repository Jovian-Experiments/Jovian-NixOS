{ pkgs, ...}: let
 hpkgs = pkgs.haskell.packages.ghc984; 
in hpkgs.callCabal2nix "update-decky-plugins" ./. { } 
