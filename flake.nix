{
  description = "NixOS on the Steam Deck";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-github-actions = {
      url = "github:zhaofengli/nix-github-actions/matrix-name";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-github-actions }: let
    supportedSystems = [ "x86_64-linux" ];
    eachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowAliases = false;
          allowUnfree = true;
        };
        overlays = [ self.overlays.default ];
      };
    in f pkgs);
  in {
    legacyPackages = eachSupportedSystem (pkgs: pkgs.jovianPackages);

    nixosModules = rec {
      default = jovian;
      jovian = ./modules;
    };

    overlays = rec {
      default = jovian;
      jovian = import ./overlay.nix;
    };

    checks = self.legacyPackages;

    githubActions = nix-github-actions.lib.mkGithubMatrix {
      inherit (self) checks;
    };

    devShells = eachSupportedSystem (pkgs: {
      default = pkgs.mkShell {
        packages = let
          pyenv = pkgs.python3.withPackages (ps: [
            ps.colorama
            ps.httpx
            ps.toml
            (ps.callPackage ./support/manifest/pyalpm.nix {})
          ]); 
        in [ pyenv ];
      };
    });
  };
}
