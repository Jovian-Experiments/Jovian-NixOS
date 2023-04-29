{ stdenv, lib, shellcheck }:

stdenv.mkDerivation rec {
  pname = "tinydm-jovian";
  version = "1.1.3";

  src = ./tinydm-run-session.sh;

  nativeBuildInputs = [ shellcheck ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    shellcheck $src
    install -Dm755 $src $out/bin/tinydm-run-session

    runHook postInstall
  '';
}
