{ fetchFromGitHub }:

let
  version = "20220825.1";
in (fetchFromGitHub {
  name = "jupiter-hw-support-${version}";
  owner = "Jovian-Experiments";
  repo = "jupiter-hw-support";
  rev = "jupiter-${version}";
  sha256 = "sha256-Xd8J6TiNbUXRGDAwqtvK1gdJPaaH+JMY1CbuHlddWEg=";
}) // {
  inherit version;
}
