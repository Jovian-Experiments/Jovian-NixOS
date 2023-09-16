{ fetchFromGitHub }:

let
  version = "20230908.1";
in (fetchFromGitHub {
  name = "jupiter-hw-support-${version}";
  owner = "Jovian-Experiments";
  repo = "jupiter-hw-support";
  rev = "jupiter-${version}";
  hash = "sha256-3VCvZUxqOiCc/ZqJmPrz+YAvRwZ58I6V+Jwej7kK4bY=";
}) // {
  inherit version;
}
