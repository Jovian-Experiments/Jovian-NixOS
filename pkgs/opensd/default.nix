{ stdenv
, lib
, fetchFromGitLab
, cmake
}:
stdenv.mkDerivation {
  pname = "opensd";
  version = "unstable-2022-12-19";

  src = fetchFromGitLab {
    owner = "open-sd";
    repo = "opensd";
    rev = "80dad94ada2d238018e88b442244494e57c98415";
    sha256 = "sha256-ilgy4M8sWV4JvfldXO42zik6McGv3E7ztBd9u+mTkFY=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [];

  cmakeFlags = [
    "-DUDEV_RULE_DIR=${placeholder "out"}/lib/udev/rules.d"
    "-DOPT_INSTALL_GROUP=OFF"
  ];

  meta = {
    description = "Userspace driver for Steam Deck input";
    license = lib.licenses.gpl3Plus;
  };
}
