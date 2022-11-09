{ fetchFromGitHub }:

let
  version = "20221108.1";
in (fetchFromGitHub {
  name = "jupiter-hw-support-${version}";
  owner = "Jovian-Experiments";
  repo = "jupiter-hw-support";
  rev = "jupiter-${version}";
  sha256 = "sha256-qb/YOWsBm213ChTM05XCehtX2zhYvXVxOgUMfdJpE9E=";
}) // {
  inherit version;
}
