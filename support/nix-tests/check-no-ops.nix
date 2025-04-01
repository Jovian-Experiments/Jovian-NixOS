#!/usr/bin/env nix-instantiate
#
# SPDX-License-Identifier: MIT
#
# Author: Samuel Dionne-Riel
#
# What's this? A shebang and +x in my Nix expression??
# ¯\_(ツ)_/¯
#
# Test that eval for unconfigured modules are no-ops.
#
# Origin: https://gitlab.com/samueldr/nixos-configuration/-/blob/cb5c6a1671ebeb1250e4f00e89787f15f45a37f1/modules/tests/check-no-ops.nix
#

let nixpkgs = ../../nixpkgs.nix; in
{ pkgs ? import nixpkgs {} }:

let
  baseCfg = {
    # Prevent stray warnings
    system.stateVersion = "00.00";
    # Ignore bootloader asserts
    boot.isContainer = true;
    # Manual builds will differ since new options are added. This is okay.
    documentation.nixos.enable = false;
  };
  compareEvals = a: b: a.config.system.build.toplevel == b.config.system.build.toplevel;
  evalConfig = cfg: (import (pkgs.path + "/nixos")) { configuration = { imports = [ cfg baseCfg ]; }; };
  evalModule = module: evalConfig { imports = [ module ]; };
  virginEval = evalConfig {};
  modules = [
    ../../modules
  ];
in
map (modulePath:
  let
    moduleEval = evalConfig modulePath;
    toplevel = moduleEval.config.system.build.toplevel;
    vToplevel = virginEval.config.system.build.toplevel;
  in
  if !(compareEvals moduleEval virginEval)
  then
    builtins.throw ''
      Module '${toString modulePath}' is not a no-op.
             ${toString modulePath} != virginEval
             ${toplevel} != ${vToplevel}
    ''
    toplevel
  else toplevel
) modules
