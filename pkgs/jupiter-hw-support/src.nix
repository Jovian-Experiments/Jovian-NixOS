{ 
  stdenv, 
  fetchFromGitHub, 
  substituteAll, 
  jovian-steam-protocol-handler, 
  coreutils,
  systemd,
  util-linux,
}:

stdenv.mkDerivation rec {
  pname = "jupiter-hw-support-source";
  version = "20240313.1";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "jupiter-hw-support";
    rev = "jupiter-${version}";
    hash = "sha256-cRALn61/Wa2nD4W3q7Bm+rYeZAWp2T7aB8mifupN1pk=";
  };

  patches = [
    (substituteAll {
      handler = jovian-steam-protocol-handler;
      coreutils = coreutils;
      systemd = systemd;
      utilLinux = util-linux;
      src = ./jovian.patch;
    })
    # Fix controller updates with python-hid >= 1.0.6
    ./hid-1.0.6.patch
  ];

  installPhase = ''
    cp -r . $out
  '';
}
