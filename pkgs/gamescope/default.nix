{
  gamescope',
  fetchFromGitHub,
}:

# NOTE: vendoring gamescope for the time being since we want to match the
#       version shipped by the vendor, ensuring feature level is equivalent.

gamescope'.overrideAttrs (old: rec {
  version = "3.17.0";

  src = fetchFromGitHub {
    owner = "ValveSoftware";
    repo = "gamescope";
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-7+KC69Ps86IkICMJdtg2x9b0A6SwE7ITKP0yibZ2bx8=";
  };
})
