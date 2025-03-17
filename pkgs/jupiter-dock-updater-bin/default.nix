{ stdenv
, fetchFromGitHub
, autoPatchelfHook
, makeWrapper
, libusb1
}:

stdenv.mkDerivation(finalAttrs: {
  pname = "jupiter-dock-updater-bin";
  version = "20250220.02";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "jupiter-dock-updater-bin";
    rev = "jupiter-${finalAttrs.version}";
    hash = "sha256-R9BsjmHeEo8N96jIDPe1TValcyK0g6oNIQBM7bGmP1E=";
  };

  buildInputs = [
    libusb1
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
