{
  description = "NixOS on the Steam Deck";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    inherit (nixpkgs) lib;

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

    checks = eachSupportedSystem (pkgs: let
      overlayContents = builtins.attrNames (import ./overlay.nix {} {})
        ++ [ "steam" ];
      jobs = lib.foldl (ret: f: f ret) overlayContents [
        (map (attr: lib.nameValuePair attr pkgs.${attr}))
        (builtins.filter (job: lib.isDerivation job.value))
        builtins.listToAttrs
      ];
    in jobs);
  };
}
