{ callPackage, fetchFromGitHub, git, ... }@args:

(callPackage ./upstream (removeAttrs args ["callPackage" "git"])).overrideAttrs (old: {
  version = "0.7.0.r63";
  src = fetchFromGitHub {
    owner = "flightlessmango";
    repo = "MangoHud";

    rev = "fd4b06f8764a999194da95cb2ec45a9baed807bb";
    hash = "sha256-CXrQNt9P2HMLS+zqG7UUsZvyWTv4lhfJfQ4QYUJ8aZ8=";
  };

  nativeBuildInputs = old.nativeBuildInputs ++ [ git ];
})
