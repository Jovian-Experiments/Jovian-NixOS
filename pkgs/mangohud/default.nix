{ callPackage, fetchFromGitHub, git, ... }@args:

(callPackage ./upstream (removeAttrs args ["callPackage" "git"])).overrideAttrs (old: {
  version = "0.7.0.r78";
  src = fetchFromGitHub {
    owner = "flightlessmango";
    repo = "MangoHud";

    rev = "c5c82dbbae846b5ea2bf920810fa2ede4a6979f8";
    hash = "sha256-386N+pzCAH+VCTCaMRID4VT9SxnlQuQ7vwmD2+sVsKs=";
  };

  nativeBuildInputs = old.nativeBuildInputs ++ [ git ];
})
