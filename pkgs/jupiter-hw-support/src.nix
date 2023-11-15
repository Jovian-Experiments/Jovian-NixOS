{ 
  applyPatches, 
  fetchFromGitHub, 
  substituteAll, 
  jovian-steam-protocol-handler, 
  systemd,
}:

let
  version = "20231114.1";
in (applyPatches {
  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "jupiter-hw-support";
    rev = "jupiter-${version}";
    hash = "sha256-IXEqWNTuzO9HVwHDG+2UI4ALXGcTk9joQb/GjkmsiH0=";
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
