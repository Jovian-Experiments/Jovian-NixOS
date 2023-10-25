{ 
  applyPatches, 
  fetchFromGitHub, 
  substituteAll, 
  jovian-steam-protocol-handler, 
  systemd,
}:

let
  version = "20231025.2";
in (applyPatches {
  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "jupiter-hw-support";
    rev = "jupiter-${version}";
    hash = "sha256-2984sTJKLQoTbBAwD1X3S+I3a2eGxdMC4Z1rt54D5NI=";
  };

  patches = [
    (substituteAll {
      handler = jovian-steam-protocol-handler;
      systemd = systemd;
      src = ./jovian.patch;
    })
  ];
}) // {
  inherit version;
}
