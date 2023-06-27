{ fetchFromGitHub }:

let
  version = "20230623.1";
in (fetchFromGitHub {
  name = "jupiter-hw-support-${version}";
  owner = "Jovian-Experiments";
  repo = "jupiter-hw-support";
  rev = "jupiter-${version}";
  hash = "sha256-40xx9NFFIQ2KNVPELrDzQU4cGUzaTzCub/NTd/DKoxs=";
}) // {
  inherit version;
}
