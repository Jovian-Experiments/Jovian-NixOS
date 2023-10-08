{ gamescope'
, fetchpatch
, fetchFromGitHub
, substituteAll
, glm
, gbenchmark
}:

# NOTE: vendoring gamescope for the time being since we want to match the
#       version shipped by the vendor, ensuring feature level is equivalent.

let
  version = "3.12.6";
  hash = "sha256-xQPRUO7UivfdoVf2MWfRI6l2T8n+gGqhQyj068fr7Sg=";

  joshShaders = fetchFromGitHub {
    owner = "Joshua-Ashton";
    repo = "GamescopeShaders";
    rev = "v0.1";
    hash = "sha256-gR1AeAHV/Kn4ntiEDUSPxASLMFusV6hgSGrTbMCBUZA=";
  };
in
gamescope'.overrideAttrs({ buildInputs, postPatch ? "", postInstall ? "", ... }: {
  name = "gamescope-${version}";
  src = fetchFromGitHub {
    owner = "ValveSoftware";
    repo = "gamescope";
    rev = "refs/tags/${version}";
    fetchSubmodules = true;
    inherit hash;
  };

  # (We are purposefully clobbering the patches from Nixpkgs here)
  patches = [
    (fetchpatch {
      url = "https://raw.githubusercontent.com/NixOS/nixpkgs/770f6182ac3084eb9ed836e1f34fce0595c905db/pkgs/applications/window-managers/gamescope/use-pkgconfig.patch";
      sha256 = "sha256-BqP20qoVH47xT/Pn4P9V5wUvHK/AJivam0Xenr8AbGk=";
    })
    ./jovian.patch
  ];

  # We can't substitute the patch itself because substituteAll is itself a derivation, 
  # so `placeholder "out"` ends up pointing to the wrong place
  postPatch = ''
    substituteInPlace src/reshade_effect_manager.cpp --replace "@out@" "$out"
  '';

  buildInputs = buildInputs ++ [
    gbenchmark
    glm
  ];

  postInstall = postInstall + ''
    mkdir -p $out/share/gamescope/reshade
	  cp -r ${joshShaders}/* $out/share/gamescope/reshade/
  '';
})
