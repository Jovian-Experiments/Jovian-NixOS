{ 
  applyPatches, 
  fetchFromGitHub, 
  substituteAll, 
  jovian-steam-protocol-handler, 
  systemd,
}:

let
  version = "20231205.1";
in (applyPatches {
  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "jupiter-hw-support";
    rev = "jupiter-${version}";
    hash = "sha256-UqfvfJbK82aqHidsra4OTXSmsd40xTyfx9ARKlFAjBM=";
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
