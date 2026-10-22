{
  gamescope',
  fetchFromGitHub,
  fetchpatch,
}:

# NOTE: vendoring gamescope for the time being since we want to match the
#       version shipped by the vendor, ensuring feature level is equivalent.

gamescope'.overrideAttrs (old: rec {
  version = "3.16.30.1";

  src = fetchFromGitHub {
    owner = "ValveSoftware";
    repo = "gamescope";
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-LZgYvKHmWb/SZfnQ2FxnrckXsROUz50oJZ39bnGIB3A=";
  };

  # patch not applied upstream yet, but applied in SteamOS PKGBUILD, improves hibernate behavior
  patches = old.patches or [ ] ++ [
    (fetchpatch {
      url = "https://raw.githubusercontent.com/Jovian-Experiments/PKGBUILDs-mirror/1b935abf7bebc26d65af5c3c2684e722f433cee4/0001-Turn-off-screen-during-system-sleep.patch";
      hash = "sha256-eoiulCAt12GHbXU3D756UGPxU9BJFzPaIljPwaQAeNE=";
    })
  ];
})
