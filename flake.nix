{
  description = "NixOS on the Steam Deck";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    supportedSystems = [ "x86_64-linux" ];
    eachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ self.overlays.default ];
      };
    in f pkgs);
  in {
    legacyPackages = eachSupportedSystem (pkgs: pkgs);

    nixosModules = rec {
      default = jovian;
      jovian = ./modules;
    };

    overlays = rec {
      # TODO: Minimize diff while making `nix flake check` pass
      default = jovian;
      jovian = final: prev: import ./overlay.nix final prev;
    };
  };
}
