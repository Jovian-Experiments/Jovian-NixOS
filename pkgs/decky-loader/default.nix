{ lib
, stdenv
, fetchFromGitHub
, fetchpatch
, nodePackages
, nodejs
, python3
}:
let
  version = "2.10.5";
  hash = "sha256-TSw7Vc6Gnl2G7WIu8nElqjY54eY+LPrGF+k5Fl7hCPw=";
  npmHash = "sha256-FyrFVHRCJX/PUGilLpiRaQwcDUO9edNWCvN/3ugVejQ=";

  src = fetchFromGitHub {
    owner = "SteamDeckHomebrew";
    repo = "decky-loader";
    rev = "v${version}";
    inherit hash;
  };

  frontendDeps = stdenv.mkDerivation {
    name = "decky-loader-frontend-deps-${version}.tar.gz";
    inherit src;

    nativeBuildInputs = [ nodePackages.pnpm ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild

      export SOURCE_DATE_EPOCH=1
      cd frontend
      pnpm i --ignore-scripts --ignore-pnpmfile --frozen-lockfile --node-linker=hoisted

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      rm node_modules/.modules.yaml
      tar -czf $out --owner=0 --group=0 --numeric-owner --format=gnu \
        --mtime="@$SOURCE_DATE_EPOCH" --sort=name \
        node_modules

      runHook postInstall
    '';

    outputHashMode = "flat";
    outputHashAlgo = "sha256";
    outputHash = npmHash;
  };

  frontend = stdenv.mkDerivation {
    pname = "decky-loader-frontend";
    inherit version src;

    nativeBuildInputs = [ nodejs nodePackages.pnpm ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild

      pushd frontend
      tar xf ${frontendDeps}
      patchShebangs --build node_modules
      pnpm build
      popd

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      cp -r backend/static $out

      runHook postInstall
    '';
  };

  pythonEnv = python3.withPackages (py: with py; [
    aiohttp
    aiohttp-jinja2
    aiohttp-cors
    watchdog
    certifi

    click # shotty
  ]);

  loader = stdenv.mkDerivation {
    pname = "decky-loader";
    inherit version src;

    patches = [
      # Patches submitted upstream: https://github.com/SteamDeckHomebrew/decky-loader/pull/528
      # FIXME: remove when merged
      (fetchpatch {
        url = "https://github.com/SteamDeckHomebrew/decky-loader/commit/e3a8de2490fea942edad4c0a8971a3958cc01d9b.patch";
        hash = "sha256-0klVKBvywCXfak8rdB3k4sK/eN/fcY42C29+J1W4pOM=";
      })
      (fetchpatch {
        url = "https://github.com/SteamDeckHomebrew/decky-loader/commit/89f37f4f547ff0d78783899df80a046bc864c48e.patch";
        hash = "sha256-9+shHrOJntHrqFbdsuBMD5GCQSx7DH3L1FLJihW9xCg=";
      })
    ];

    buildInputs = [ pythonEnv ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib
      cp -r backend $out/lib/decky-loader
      cp -r plugin $out/lib/decky-loader/

      ln -s ${frontend} $out/lib/decky-loader/static

      mkdir $out/bin
      cat << EOF >$out/bin/decky-loader
      #!/bin/sh
      export PATH=${pythonEnv}/bin:$PATH
      export DECKY_VERSION=v${version}
      exec ${pythonEnv}/bin/python3 $out/lib/decky-loader/main.py
      EOF
      chmod +x $out/bin/decky-loader

      runHook postInstall
    '';

    passthru = {
      inherit frontendDeps;
      python = python3;
    };

    meta = with lib; {
      description = "A plugin loader for the Steam Deck";
      homepage = "https://github.com/SteamDeckHomebrew/decky-loader";
      platforms = platforms.linux;
      license = licenses.gpl2Only;
    };
  };
in loader
