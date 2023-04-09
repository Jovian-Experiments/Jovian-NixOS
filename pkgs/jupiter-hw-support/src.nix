{ fetchFromGitHub }:

let
  version = "20230327.1";
in (fetchFromGitHub {
  name = "jupiter-hw-support-${version}";
  owner = "Jovian-Experiments";
  repo = "jupiter-hw-support";
  rev = "jupiter-${version}";
  sha256 = "sha256-kAxkvsRawQWty2aW1EDrpUy25pvOhp3jIFBSyPvHVjM=";
}) // {
  inherit version;
}
