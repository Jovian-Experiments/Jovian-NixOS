{ gamescope'
, fetchFromGitHub
, cmake
}:

# NOTE: vendoring gamescope for the time being since we want to match the
#       version shipped by the vendor, ensuring feature level is equivalent.

gamescope'.overrideAttrs(old: rec {
  version = "3.14.2-unstable-2024-02-28";

  src = fetchFromGitHub {
    owner = "ValveSoftware";
    repo = "gamescope";
    rev = "14a1db3a57612e5cfbba6d4c19688eafdc6c4043";
    fetchSubmodules = true;
    hash = "sha256-Lz2kXsxlFmYhsjH8KrapPJlsIJWxOShtCdKbpmgFBwc=";
  };

  mesonFlags = old.mesonFlags ++ ["-Davif_screenshots=disabled"];

  # Build with vendored OpenVR for now, pending https://github.com/NixOS/nixpkgs/pull/275372
  buildInputs = builtins.filter (p: p.pname != "openvr") old.buildInputs;
  # Needed to build vendored OpenVR
  nativeBuildInputs = old.nativeBuildInputs ++ [ cmake ];
})
