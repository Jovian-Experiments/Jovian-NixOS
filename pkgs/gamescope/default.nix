{
  gamescope',
  fetchFromGitHub,
  fetchpatch,
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

  # patch not applied upstream yet, but applied in SteamOS PKGBUILD, improves hibernate behavior
  patches = old.patches or [ ] ++ [
    (fetchpatch {
      url = "https://raw.githubusercontent.com/Jovian-Experiments/PKGBUILDs-mirror/refs/tags/jupiter-main/gamescope-3.17.0-1/0001-Turn-off-screen-during-system-sleep.patch";
      hash = "sha256-bJr4cyOjZ9RPG3rcza8LZMTomAs78eE2m6inROGNx4Y=";
    })
  ];
})
