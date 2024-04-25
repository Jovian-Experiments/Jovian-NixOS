{ gamescope'
, fetchFromGitHub
, libei
}:

# NOTE: vendoring gamescope for the time being since we want to match the
#       version shipped by the vendor, ensuring feature level is equivalent.

gamescope'.overrideAttrs(old: rec {
  version = "3.14.6";

  src = fetchFromGitHub {
    owner = "ValveSoftware";
    repo = "gamescope";
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-Nj66d42Ih4pD15cNuMe81sviUepVVzVX8BEP7O2p0o0=";
  };

  buildInputs = old.buildInputs ++ [ libei ];
})
