{ 
  decky-loader,
  fetchFromGitHub,
  pnpm,
}:
decky-loader.overrideAttrs rec {
  pname = "decky-loader";
  version = "3.0.2-pre3";

  src = fetchFromGitHub {
    owner = "SteamDeckHomebrew";
    repo = "decky-loader";
    rev = "v${version}";
    hash = "sha256-mWeGB2h0FB5AbUIt14d0S5f2GFYz00bFm3px6xFsQLo=";
  };

  pnpmDeps = pnpm.fetchDeps {
    inherit pname version src;
    sourceRoot = "${src.name}/frontend";
    hash = "sha256-DG1+Drr0z0QfnGYDpJw+PpINjA9PM1Rij93ePqebDSE=";
  };
}
