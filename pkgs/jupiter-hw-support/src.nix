{ 
  stdenv, 
  fetchFromGitHub, 
  substituteAll, 
  jovian-steam-protocol-handler, 
  systemd,
}:

stdenv.mkDerivation rec {
  pname = "jupiter-hw-support-source";
  version = "20240604.1";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "jupiter-hw-support";
    rev = "jupiter-${version}";
    hash = "sha256-ITFgHmpfvHnScq/YSf5WPYVYQTG58RJbj9Rhkj0hXT8=";
  };

  patches = [
    (substituteAll {
      handler = jovian-steam-protocol-handler;
      systemd = systemd;
      src = ./jovian.patch;
    })
    # Fix controller updates with python-hid >= 1.0.6
    ./hid-1.0.6.patch
  ];

  installPhase = ''
    cp -r . $out
  '';
}
