{ callPackage, fetchFromGitHub, git, ... }@args:

(callPackage ./upstream (removeAttrs args ["callPackage" "git"])).overrideAttrs (old: {
  version = "0.7.0.r54";
  src = fetchFromGitHub {
    owner = "flightlessmango";
    repo = "MangoHud";

    rev = "9393066ef87c168a55fb0e2db3d002c55544fdd6";
    hash = "sha256-WM3Z0l0rEVQ56GG0XhHu3/ao2K066GjIh25nn2QU+8A=";
  };

  nativeBuildInputs = old.nativeBuildInputs ++ [ git ];
})
