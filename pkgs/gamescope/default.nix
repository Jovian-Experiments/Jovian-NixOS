{ gamescope'
, fetchFromGitHub
, glm
, gbenchmark
, xorg
}:

# NOTE: vendoring gamescope for the time being since we want to match the
#       version shipped by the vendor, ensuring feature level is equivalent.

let
  joshShaders = fetchFromGitHub {
    owner = "Joshua-Ashton";
    repo = "GamescopeShaders";
    rev = "v0.1";
    hash = "sha256-gR1AeAHV/Kn4ntiEDUSPxASLMFusV6hgSGrTbMCBUZA=";
  };
in
gamescope'.overrideAttrs(old: rec {
  version = "3.13.16";

  src = fetchFromGitHub {
    owner = "ValveSoftware";
    repo = "gamescope";
    rev = "refs/tags/${version}";
    fetchSubmodules = true;
    hash = "sha256-VxZSRTqsEyEc8C2gNdRxik3Jx1NxB9ktQ3ALUFkDjo0=";
  };

  # Clobber unvendoring vkroots, nixpkgs version is too old
  postUnpack = null;

  # (We are purposefully clobbering the patches from Nixpkgs here)
  patches = [
    ./jovian.patch
  ];

  # We can't substitute the patch itself because substituteAll is itself a derivation, 
  # so `placeholder "out"` ends up pointing to the wrong place
  postPatch = ''
    substituteInPlace src/reshade_effect_manager.cpp --replace "@out@" "$out"
  '';

  buildInputs = old.buildInputs ++ [
    gbenchmark
    glm
    xorg.xcbutilerrors
    xorg.xcbutilwm
  ];

  mesonInstallFlags = ["--skip-subprojects"];

  postInstall = old.postInstall + ''
    mkdir -p $out/share/gamescope/reshade
	  cp -r ${joshShaders}/* $out/share/gamescope/reshade/
  '';
})
