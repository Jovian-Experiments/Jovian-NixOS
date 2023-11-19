{ lib, ... }:

{
  nixpkgs.overlays = [
    (import ../overlay.nix)
  ];

  assertions = [
    {
      assertion = lib.hasInfix "pre" lib.version;
      message = "Jovian NixOS is only validated with the nixos-unstable branch of Nixpkgs. Please upgrade your Nixpkgs version.";
    }
  ];
}
