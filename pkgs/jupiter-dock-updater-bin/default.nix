{ lib
, stdenv
, fetchFromGitHub
, autoPatchelfHook
, makeWrapper
, libusb
}:

stdenv.mkDerivation rec {
  pname = "jupiter-dock-updater-bin";
  version = "20220921.01";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "jupiter-dock-updater-bin";
    rev = "jupiter-${version}";
    hash = "sha256-rlHUHIaRBHK5KlCklPh0X0Is6D2sVhB6h6yMZZDRPUk=";
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
