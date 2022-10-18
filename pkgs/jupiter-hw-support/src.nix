{ fetchFromGitHub }:

let
  version = "20221005.1";
in (fetchFromGitHub {
  name = "jupiter-hw-support-${version}";
  owner = "Jovian-Experiments";
  repo = "jupiter-hw-support";
  rev = "jupiter-${version}";
  sha256 = "sha256-fjNRCclhGvF9YsUGri4gTVLD8KhtRr4dUCkQnU99oEo=";
}) // {
  inherit version;
}
