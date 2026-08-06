{ pipewire', fetchFromGitHub }:
pipewire'.overrideAttrs (_: {
  version = "1.6.8-1.2"; # 1.2 is a rebuild, no source changes

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "pipewire";
    rev = "1.6.8-jupiter1.1";
    hash = "sha256-6A5LldWaxMHO9D4TnoPhzvZRMZEEPcrrVNAYDf5/hGE=";
  };
})
