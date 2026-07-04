{ wireplumber', fetchFromGitHub }:
wireplumber'.overrideAttrs(_: {
  version = "0.5.14-1.6";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "wireplumber";
    rev = "0.5.14-jupiter1.6";
    hash = "sha256-uC2lmaMuJ0xHh+p8ga13W6XX89Oxbet8dHX5KDuald4=";
  };
})
