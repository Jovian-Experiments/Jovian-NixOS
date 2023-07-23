{ lib
, stdenv
, fetchFromGitHub
, nodePackages
, nodejs
, python3
}:
let
  version = "2.10.3";
  hash = "sha256-cgLnej/mO8ShzUBevGBF+a78VhQhudDvpmdwgRZ4Wm8=";
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
