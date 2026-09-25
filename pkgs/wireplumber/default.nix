{ wireplumber', fetchFromGitHub }:
wireplumber'.overrideAttrs(_: {
  version = "0.5.17-1.1";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "wireplumber";
    rev = "0.5.17-jupiter1.1";
    hash = "sha256-P7wOSSiI4p/MxsSyxNgOiooJZIyIUgTZ5LeY1Bp+kVo=";
  };
})
