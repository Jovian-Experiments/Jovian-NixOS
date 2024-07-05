{ gamescope'
, fetchFromGitHub
, cmake
}:

# NOTE: vendoring gamescope for the time being since we want to match the
#       version shipped by the vendor, ensuring feature level is equivalent.

gamescope'.overrideAttrs(old: rec {
  version = "3.14.23";

  src = fetchFromGitHub {
    owner = "ValveSoftware";
    repo = "gamescope";
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-qXwCzNGlkGmO3BkQ74tJxufmjh4dUWzIgjHzDCEShU8=";
  };

  # Force vendored OpenVR
  buildInputs = builtins.filter (p: p.pname != "openvr") old.buildInputs;
  nativeBuildInputs = old.nativeBuildInputs ++ [ cmake ];
})
