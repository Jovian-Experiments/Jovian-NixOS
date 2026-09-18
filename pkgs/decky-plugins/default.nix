{ fetchurl, lib, stdenv, unzip, ... }@args:
let
  buildDeckyPlugin =
    lib.makeOverridable ({
      stdenv ? args.stdenv,
      fetchzip ? args.fetchurl,
      unzip ? args.unzip,
      name,
      version,
      url,
      download_hash,
      meta,
      ...
    }:
    stdenv.mkDerivation {
      name = "${name}-${version}";
      src = fetchurl {
        inherit url;
        sha256 = "${download_hash}";
      };

      buildInputs = [
        unzip
      ];

      installPhase = ''
        mkdir -p $out/plugins/
        unzip $src -d $out/plugins/
      '';

      inherit meta;
    });

  generatedPackages = import ./generated.nix {
    inherit buildDeckyPlugin lib stdenv fetchurl unzip;
  };
  overrides = import ./overrides.nix;
  packages = generatedPackages // overrides;
in
packages
