#
# This test config can be checked with:
#
# ```
#  $ nix-instantiate ./support/test-configs/bad-overlaying-twice/
# ```
#
# It should error out in a controlled manner.
#
{ pkgs ? import ../../../nixpkgs.nix {} }:

let
  eval = (import (pkgs.path + "/nixos")) {
    configuration = ./configuration.nix;
  };
in
  eval.pkgs.gamescope
