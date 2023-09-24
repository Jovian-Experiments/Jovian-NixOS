{ lib
, stdenv
, fetchFromGitHub
, autoPatchelfHook
, makeWrapper
, libusb
}:

stdenv.mkDerivation(finalAttrs: {
  pname = "jupiter-dock-updater-bin";
  version = "20230714.01";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "jupiter-dock-updater-bin";
    rev = "jupiter-${finalAttrs.version}";
    hash = "sha256-tfMPBC1x4YE3Sv3GbVkQJ12CYODeHjK1cBEaw9jBZpY=";
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
