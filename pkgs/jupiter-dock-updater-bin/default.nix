{
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  makeWrapper,
  libusb1,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jupiter-dock-updater-bin";
  version = "20261116.01";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "jupiter-dock-updater-bin";
    rev = "jupiter-${finalAttrs.version}";
    hash = "sha256-MoPm2+petxI527x9uHOlgj2jx01WHgrFCJEiliinN9I=";
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
