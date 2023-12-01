{ callPackage, fetchFromGitHub, git, ... }@args:

(callPackage ./upstream (removeAttrs args ["callPackage" "git"])).overrideAttrs (old: {
  version = "0.7.0.r76";
  src = fetchFromGitHub {
    owner = "flightlessmango";
    repo = "MangoHud";

    rev = "4646e2e4f6fe3067740b9eb806679b7576231f10";
    hash = "sha256-hl3B99J/h655uZTGCGkqU5bAFqSGoBskyq8khNoVoCA=";
  };

  nativeBuildInputs = old.nativeBuildInputs ++ [ git ];
})
