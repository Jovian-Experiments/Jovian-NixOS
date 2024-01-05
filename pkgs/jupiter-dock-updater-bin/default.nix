{ lib
, stdenv
, fetchFromGitHub
, autoPatchelfHook
, makeWrapper
, libusb
}:

stdenv.mkDerivation(finalAttrs: {
  pname = "jupiter-dock-updater-bin";
  version = "20231121.01";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "jupiter-dock-updater-bin";
    rev = "jupiter-${finalAttrs.version}";
    hash = "sha256-0ynous5tUVF+0IJIPR+DKMkQKwtMCkzYHCu4VzzuYyQ=";
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
})
