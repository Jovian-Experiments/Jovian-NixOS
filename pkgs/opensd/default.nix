{ stdenv
, lib
, fetchFromGitLab
, cmake
}:
stdenv.mkDerivation {
  pname = "opensd";
  version = "unstable-2022-12-08";

  src = fetchFromGitLab {
    owner = "open-sd";
    repo = "opensd";
    rev = "6c937c9daf20bba17ca97ba5a2332dcce2d4f310";
    sha256 = "sha256-d3qZN+N8Z+aC/UPbiUEkQIWPNFBNJazje3GCi/ESi1E=";
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
