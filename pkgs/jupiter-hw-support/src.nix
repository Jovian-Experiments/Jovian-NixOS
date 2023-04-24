{ fetchFromGitHub }:

let
  version = "20230424.1";
in (fetchFromGitHub {
  name = "jupiter-hw-support-${version}";
  owner = "Jovian-Experiments";
  repo = "jupiter-hw-support";
  rev = "jupiter-${version}";
  sha256 = "sha256-NlAhfDL1bRy6qj3jM8hHiZOWlaLhi/Q0rdGbMpDDNQg=";
}) // {
  inherit version;
}
