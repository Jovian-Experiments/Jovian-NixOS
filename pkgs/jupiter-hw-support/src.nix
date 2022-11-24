{ fetchFromGitHub }:

let
  version = "20221121.1";
in (fetchFromGitHub {
  name = "jupiter-hw-support-${version}";
  owner = "Jovian-Experiments";
  repo = "jupiter-hw-support";
  rev = "jupiter-${version}";
  sha256 = "sha256-gFa0NgKQJSliaG57MF6im9Z27CXCjXu/zVQWyRan58A=";
}) // {
  inherit version;
}
