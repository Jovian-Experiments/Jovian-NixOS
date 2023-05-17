{ gamescope'
, fetchpatch
, fetchFromGitHub
, glm
, gbenchmark
}:

# NOTE: vendoring gamescope for the time being since we want to match the
#       version shipped by the vendor, which does not work without the kernel
#       version coherent with the version as shipped by the vendor.

let
  version = "3.12.0-beta5";
  hash = "sha256-KN4WsXrZSps6UQMKsqOV35mwFaJMHitaAlNYKW8Snm8=";
in
gamescope'.overrideAttrs({ buildInputs, ... }: {
  name = "gamescope-${version}";
  src = fetchFromGitHub {
    owner = "ValveSoftware";
    repo = "gamescope";
    rev = "refs/tags/${version}";
    inherit hash;
  };

  # (We are purposefully clobbering the patches from Nixpkgs here)
  patches = [
    (fetchpatch {
      url = "https://raw.githubusercontent.com/NixOS/nixpkgs/770f6182ac3084eb9ed836e1f34fce0595c905db/pkgs/applications/window-managers/gamescope/use-pkgconfig.patch";
      sha256 = "sha256-BqP20qoVH47xT/Pn4P9V5wUvHK/AJivam0Xenr8AbGk=";
    })
  ];

  buildInputs = buildInputs ++ [
    gbenchmark
    glm
  ];
})
