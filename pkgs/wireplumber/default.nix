{ wireplumber', fetchFromGitHub }:
wireplumber'.overrideAttrs (_: {
  version = "0.5.10-1.3";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "wireplumber";
    rev = "0.5.10-jupiter1.3";
    hash = "sha256-u9LJtAvD54XKyxog570mJXx3Nwgul+ZI6PI0VH4Fmm4=";
  };
})
