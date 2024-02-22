{ gamescope'
, fetchFromGitHub
, cmake
}:

# NOTE: vendoring gamescope for the time being since we want to match the
#       version shipped by the vendor, ensuring feature level is equivalent.

gamescope'.overrideAttrs(old: rec {
  version = "3.14.2";

  src = fetchFromGitHub {
    owner = "ValveSoftware";
    repo = "gamescope";
    rev = "refs/tags/${version}";
    fetchSubmodules = true;
    hash = "sha256-Ym1kl9naAm1MGlxCk32ssvfiOlstHiZPy7Ga8EZegus=";
  };

  mesonFlags = old.mesonFlags ++ ["-Davif_screenshots=disabled"];

  # Build with vendored OpenVR for now, pending https://github.com/NixOS/nixpkgs/pull/275372
  buildInputs = builtins.filter (p: p.pname != "openvr") old.buildInputs;
  # Needed to build vendored OpenVR
  nativeBuildInputs = old.nativeBuildInputs ++ [ cmake ];
})
