{
  stdenv,
  fetchFromGitHub,
  cmake,
  kdePackages,
  qt6,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "kcgroups";
  version = "dmemcg-experimental-4";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "kcgroups";
    tag = "kcgroups-${finalAttrs.version}";
    hash = "sha256-nporbLRAUHQoKcmkyNkkxerciAjEZqBm4pjmhsJVtVU=";
  };

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
  ];

  cmakeFlags = [
    "-DQT_MAJOR_VERSION=6"
  ];

  buildInputs = [
    qt6.qtbase
  ];

  dontWrapQtApps = true;
})
