{ lib, ... }:

{
  nixpkgs.overlays = [
    (import ../overlay.nix)
  ];

  assertions = [
    {
      assertion = lib.versionAtLeast lib.version "23.11";
      message = "Jovian NixOS is only validated with the nixos-unstable branch of Nixpkgs. Please upgrade your Nixpkgs version.";
    }
  ];
}
