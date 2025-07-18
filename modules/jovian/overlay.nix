{ config, lib, ... }:
let
  inherit (lib)
    mkIf
    mkOption
    types
  ;
  cfg = config.jovian.overlay;
in
{
  options = {
    jovian.overlay = {
      enable = mkOption {
        type = types.bool;
        default = config.jovian.steam.enable;
        defaultText = "config.jovian.steam.enable";
        description = ''
          Whether to enable the provided overlay over Nixpkgs.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      (import ../../overlay.nix)
    ];

    assertions = [
      {
        # Can't use 23.11 here because git versions are tracked as 23.11pre,
        # which is considered to be < 23.11.
        assertion = lib.versionAtLeast lib.version "23.10";
        message = "Jovian NixOS is only validated with the nixos-unstable branch of Nixpkgs. Please upgrade your Nixpkgs version.";
      }
    ];
  };
}

