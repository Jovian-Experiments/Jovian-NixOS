{ fetchFromGitHub }:

let
  version = "20221010.1";
in (fetchFromGitHub {
  name = "jupiter-hw-support-${version}";
  owner = "Jovian-Experiments";
  repo = "jupiter-hw-support";
  rev = "jupiter-${version}";
  sha256 = "sha256-OjrsUUrSQOxrdECyVSSRMelKZsgmI3pAwsipvcPSSzE=";
}) // {
  inherit version;
}
