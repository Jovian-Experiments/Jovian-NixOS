{ fetchFromGitHub }:

let
  version = "20220729.1";
in (fetchFromGitHub {
  name = "jupiter-hw-support-${version}";
  owner = "Jovian-Experiments";
  repo = "jupiter-hw-support";
  rev = "jupiter-${version}";
  sha256 = "sha256-DpIY3WjNnk8qrp5ZmqzROhKFJpDvLjuBS+7acCR/8Gk=";
}) // {
  inherit version;
}
