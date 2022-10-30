{ stdenv
, lib
, fetchFromGitLab
, cmake
}:
stdenv.mkDerivation {
  pname = "opensd";
  version = "unstable-2022-10-28";

  src = fetchFromGitLab {
    owner = "open-sd";
    repo = "opensd";
    rev = "e00bc74e516769dbb4adeebde3102657f8a486eb";
    sha256 = "sha256-Jl04pXpE5Rk4MSnezIvvbN6/W29L3NgfcP/Fd5kn2uQ=";
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
