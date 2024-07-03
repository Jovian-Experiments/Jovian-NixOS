{ version, hash, npmHash }:
{ lib
, stdenv
, fetchFromGitHub
, nodePackages
, nodejs
, pnpm
, cacert
, python3
, psmisc
}:
let
  src = fetchFromGitHub {
    owner = "SteamDeckHomebrew";
    repo = "decky-loader";
    rev = "v${version}";
    inherit hash;
  };

  frontend = stdenv.mkDerivation rec {
    pname = "decky-loader-frontend";
    inherit version src;

    pnpmDeps = pnpm.fetchDeps {
      inherit pname version src;
      sourceRoot = "${src.name}/frontend";
      hash = npmHash;
    };

    pnpmRoot = "frontend";

    nativeBuildInputs = [
      nodejs
      pnpm.configHook
    ];


    buildPhase = ''
      runHook preBuild

      pushd frontend
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
      # hacks to make Decky behave on NixOS
      ./jovian.patch
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
      # psmisc used for killall
      export PATH=${pythonEnv}/bin:${psmisc}/bin:\$PATH
      export DECKY_VERSION=v${version}
      exec ${pythonEnv}/bin/python3 $out/lib/decky-loader/main.py
      EOF
      chmod +x $out/bin/decky-loader

      runHook postInstall
    '';

    passthru.python = python3;

    meta = with lib; {
      description = "A plugin loader for the Steam Deck";
      homepage = "https://github.com/SteamDeckHomebrew/decky-loader";
      platforms = platforms.linux;
      license = licenses.gpl2Only;
    };
  };
in loader
