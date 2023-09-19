{ callPackage, fetchFromGitHub, git, ... }@args:

(callPackage ./upstream (removeAttrs args ["callPackage" "git"])).overrideAttrs (old: {
  version = "0.7.0.rc1.r4";
  src = fetchFromGitHub {
    owner = "flightlessmango";
    repo = "MangoHud";

    rev = "1a0abc65dfb44853813e6e437bd71747bac089e5";
    hash = "sha256-XOoVAcNrKphuoUbt8GDTX2p/JtCMf87DLRycHdINTBA=";
  };

  nativeBuildInputs = old.nativeBuildInputs ++ [ git ];
})
