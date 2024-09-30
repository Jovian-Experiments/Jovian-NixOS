{ 
  stdenv, 
  fetchFromGitHub, 
  substituteAll, 
  jovian-steam-protocol-handler, 
  systemd,
}:

stdenv.mkDerivation rec {
  pname = "jupiter-hw-support-source";
  version = "20240919.2";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "jupiter-hw-support";
    rev = "jupiter-${version}";
    hash = "sha256-K3NhBWiKObi4JVg28r+rqanjZGkHTC2QL/u09B7sRA8=";
  };

  patches = [
    (substituteAll {
      handler = jovian-steam-protocol-handler;
      systemd = systemd;
      src = ./automount-fix-system-paths.patch;
    })
    # Fix controller updates with python-hid >= 1.0.6
    ./hid-1.0.6.patch
    # Remove `deck` username assumption
    ./0001-Jovian-Ensure-automounting-works-for-any-UID-1000-us.patch
    # Minor fixes against silly environments
    ./0001-steamos-automount-Harden-against-missing-run-media.patch
    ./0001-format-device-Harden-against-mountpoint-being-listed.patch
  ];

  installPhase = ''
    cp -r . $out
  '';
}
