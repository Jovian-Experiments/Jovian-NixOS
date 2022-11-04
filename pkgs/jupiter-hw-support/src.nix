{ fetchFromGitHub }:

let
  version = "20221102.1";
in (fetchFromGitHub {
  name = "jupiter-hw-support-${version}";
  owner = "Jovian-Experiments";
  repo = "jupiter-hw-support";
  rev = "jupiter-${version}";
  sha256 = "sha256-9wBY8KYHzj+WSS5fhIQEtZrNMaA+XJXWIsL6J9+NXL4=";
}) // {
  inherit version;
}
