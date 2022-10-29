{ lib
, stdenv
, fetchFromGitHub
, autoPatchelfHook
, makeWrapper
, libusb
}:

stdenv.mkDerivation rec {
  pname = "jupiter-dock-updater-bin";
  version = "20221026.01";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "jupiter-dock-updater-bin";
    rev = "jupiter-${version}";
    hash = "sha256-Iu9oAy9wVIMowD+wOABIbLjA0Vgr7xndlz0/jhuDuVg=";
  };

  buildInputs = [
    libusb
  ];

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r packaged/usr/lib $out/
    makeWrapper $out/lib/jupiter-dock-updater/jupiter-dock-updater.sh $out/bin/jupiter-dock-updater

    runHook postInstall
  '';
}
