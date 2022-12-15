{ fetchFromGitHub }:

let
  version = "20221213.1";
in (fetchFromGitHub {
  name = "jupiter-hw-support-${version}";
  owner = "Jovian-Experiments";
  repo = "jupiter-hw-support";
  rev = "jupiter-${version}";
  sha256 = "sha256-0cHS2RU3qYmE2vfRm280jAU82c+OoZ4V5LBoSbqYXu0=";
}) // {
  inherit version;
}
