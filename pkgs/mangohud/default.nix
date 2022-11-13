{ mangohud, fetchFromGitHub }:

mangohud.overrideAttrs (old: {
  version = "unstable-2022-09-18";
  src = fetchFromGitHub {
    owner = "flightlessmango";
    repo = "MangoHud";

    # As shipped in SteamOS 3 repo 0.6.8.r17.gebb0f96
    rev = "ebb0f969dea2c5df1600e6e299cd5665920e0020";
    hash = "sha256-+luu/YjSNdhUl3TDyNrsvSiZOL3Jpfx0wv3MPe+vtyQ=";
  };
})
