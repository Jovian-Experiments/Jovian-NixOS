{ fetchFromGitHub }:

let
  version = "20230201";
in (fetchFromGitHub {
  name = "jupiter-hw-support-${version}";
  owner = "Jovian-Experiments";
  repo = "jupiter-hw-support";
  rev = "jupiter-${version}";
  sha256 = "sha256-UwdkEvohPp/y2DXElAeWxFAH6C9No6ZG6SGr33fY220=";
}) // {
  inherit version;
}
