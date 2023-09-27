{ 
  applyPatches, 
  fetchFromGitHub, 
  substituteAll, 
  jovian-steam-protocol-handler, 
  systemd,
}:

let
  version = "20230918.1";
in (applyPatches {
  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "jupiter-hw-support";
    rev = "jupiter-${version}";
    hash = "sha256-w5rX8h/P4gCYV6WVj9XhyVrg1VUQ+z+ev8ijiPgl0u0=";
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
