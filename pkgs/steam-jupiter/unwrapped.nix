# pkgs/games/steam/steam.nix with the Steam Deck client fat bootstrap
#
# This allows the Steam Deck UI to start on a fresh installation
# (i.e., have not launched Steam at all before).

{ steam-original, fetchurl }:

let
  version = "1.0.0.79-1.1";
  bundle = fetchurl {
    url = "https://steamdeck-packages.steamos.cloud/archlinux-mirror/sources/jupiter-main/steam-jupiter-stable-${version}.src.tar.gz";
    hash = "sha256-izCFnX4Qk2M+jNtT3urGQoNbVGEN3v0SU3LfTWqS3ho=";
  };

in steam-original.overrideAttrs (old: {
  pname = "steam-jupiter-original";
  inherit version;

  postInstall = (old.postInstall or "") + ''
    >&2 echo ":: Injecting Steam Deck client bootstrap..."
    tar xvf ${bundle}
    cp steam-jupiter-stable/steam_jupiter_stable_bootstrapped_*.tar.xz $out/lib/steam/bootstraplinux_ubuntu12_32.tar.xz
  '';
})
