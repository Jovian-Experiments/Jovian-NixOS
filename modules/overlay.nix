{ lib, ... }:

{
  nixpkgs.overlays = [
    (import ../overlay.nix)
  ];

  assertions = [
    {
      assertion = lib.hasInfix lib.version "pre";
      message = "Jovian NixOS is only validated with the nixos-unstable branch of Nixpkgs. Please upgrade your Nixpkgs version.";
    }
  ];
}
