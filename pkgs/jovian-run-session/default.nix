{ stdenv, lib, fetchFromGitHub, shellcheck }:

stdenv.mkDerivation rec {
  name = "jovian-run-session";

  src = ./jovian-run-session.sh;

  nativeBuildInputs = [ shellcheck ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    shellcheck $src
    install -Dm755 $src $out/bin/jovian-run-session

    runHook postInstall
  '';
}
