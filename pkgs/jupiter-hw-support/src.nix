{ fetchFromGitHub }:

let
  version = "20230918.1";
in (fetchFromGitHub {
  name = "jupiter-hw-support-${version}";
  owner = "Jovian-Experiments";
  repo = "jupiter-hw-support";
  rev = "jupiter-${version}";
  hash = "sha256-w5rX8h/P4gCYV6WVj9XhyVrg1VUQ+z+ev8ijiPgl0u0=";
}) // {
  inherit version;
}
