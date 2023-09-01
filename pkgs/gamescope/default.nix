{ gamescope'
, fetchpatch
, fetchFromGitHub
, glm
, gbenchmark
}:

# NOTE: vendoring gamescope for the time being since we want to match the
#       version shipped by the vendor, ensuring feature level is equivalent.

let
  version = "3.12.5";
  hash = "sha256-u4pnKd5ZEC3CS3E2i8E8Wposd8Tu4ZUoQXFmr0runwE=";
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
