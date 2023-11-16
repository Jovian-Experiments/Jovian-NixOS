{ 
  applyPatches, 
  fetchFromGitHub, 
  substituteAll, 
  jovian-steam-protocol-handler, 
  systemd,
}:

let
  version = "20231115.1";
in (applyPatches {
  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "jupiter-hw-support";
    rev = "jupiter-${version}";
    hash = "sha256-m36uJMdMpONXUMm33VcsoX+zMr/5MosU7ivq7wxogvw=";
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
