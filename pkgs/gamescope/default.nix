{ gamescope'
, fetchpatch
, fetchFromGitHub
}:

# NOTE: vendoring gamescope for the time being since we want to match the
#       version shipped by the vendor, ensuring feature level is equivalent.
#       We're also patching-in features.

gamescope'.overrideAttrs(old: rec {
  version = "3.16.4";

  src = fetchFromGitHub {
    owner = "ValveSoftware";
    repo = "gamescope";
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-2AxqvZA1eZaJFKMfRljCIcP0M2nMngw0FQiXsfBW7IA=";
  };

  patches = old.patches ++ [
    # wlserver: Sythesize QAM combo on F22
    # wlserver: Steam Overlay shortcut synthesis on F21
    # wlserver: Synthesize sythetic steam overlay on keyboard input
    (fetchpatch {
      url = "https://github.com/ValveSoftware/gamescope/compare/35cb4fbb2399df205b772295451b875f784ec8d0...2335543009f123d16a141502aa1fe899b38c319f.patch";
      hash = "sha256-UT5KrnoQ+45AYh73Og1pxVlMRHaJvBULnQhJl8h+SW0=";
    })
  ];
})
