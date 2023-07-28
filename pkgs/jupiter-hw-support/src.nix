{ fetchFromGitHub }:

let
  version = "20230728.1";
in (fetchFromGitHub {
  name = "jupiter-hw-support-${version}";
  owner = "Jovian-Experiments";
  repo = "jupiter-hw-support";
  rev = "jupiter-${version}";
  hash = "sha256-hDxW9q2vqvCuPq82EyESdy+2xzPw+i7kx7uJ3UzlYbg=";
}) // {
  inherit version;
}
