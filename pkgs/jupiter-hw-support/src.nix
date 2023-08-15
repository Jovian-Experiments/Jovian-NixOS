{ fetchFromGitHub }:

let
  version = "20230810.2";
in (fetchFromGitHub {
  name = "jupiter-hw-support-${version}";
  owner = "Jovian-Experiments";
  repo = "jupiter-hw-support";
  rev = "jupiter-${version}";
  hash = "sha256-/xlrMXcQT/l1qj40EUD1LlCT4iQ4okypxPh4S6zztTY=";
}) // {
  inherit version;
}
