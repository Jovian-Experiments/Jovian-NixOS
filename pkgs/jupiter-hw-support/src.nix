{ fetchFromGitHub }:

let
  version = "20230522.1";
in (fetchFromGitHub {
  name = "jupiter-hw-support-${version}";
  owner = "Jovian-Experiments";
  repo = "jupiter-hw-support";
  rev = "jupiter-${version}";
  sha256 = "sha256-j8+Vc/gEpKXP2WcElZa3MP1HL+urOh4Eca9InJ+JAPY=";
}) // {
  inherit version;
}
