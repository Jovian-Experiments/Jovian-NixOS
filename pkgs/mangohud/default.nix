{ callPackage, fetchFromGitHub, ... }@args:

(callPackage ./upstream (removeAttrs args ["callPackage"])).overrideAttrs (old: {
  version = "unstable-2023-04-23";
  src = fetchFromGitHub {
    owner = "flightlessmango";
    repo = "MangoHud";

    # As shipped in SteamOS 3 repo 0.6.9.1.r16.g1093de8
    rev = "1093de8c4406a96642e139243911a571874c3d11";
    hash = "sha256-D4E3C8+jcbEqoQ1Po8Bh5H3k0Fu36DttIaSjUjaRadc=";
  };
})
