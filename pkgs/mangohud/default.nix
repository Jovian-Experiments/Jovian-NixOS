{ callPackage, fetchFromGitHub, ... }@args:

(callPackage ./upstream (removeAttrs args ["callPackage"])).overrideAttrs (old: {
  version = "unstable-2023-04-25";
  src = fetchFromGitHub {
    owner = "flightlessmango";
    repo = "MangoHud";

    # As shipped in SteamOS 3 repo 0.6.9.1.r22.g1d8f9f6
    rev = "1d8f9f660135f460f4109e98d8725a75c908246a";
    hash = "sha256-vyqMbdrc5s3vS5apFfzz0rI/y3bVlU8n/BXi4i+UkLU=";
  };
})
