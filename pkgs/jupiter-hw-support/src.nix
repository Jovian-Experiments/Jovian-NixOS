{ 
  stdenv, 
  fetchFromGitHub, 
  substituteAll, 
  jovian-steam-protocol-handler, 
  systemd,
}:

stdenv.mkDerivation rec {
  pname = "jupiter-hw-support-source";
  version = "20240617.1";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "jupiter-hw-support";
    rev = "jupiter-${version}";
    hash = "sha256-MqGN2T7k5n74y3Bl3+cCo6GyMlOd8MxTXy0ly5EsHrE=";
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
