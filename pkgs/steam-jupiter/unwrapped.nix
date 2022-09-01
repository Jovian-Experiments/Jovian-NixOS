# pkgs/games/steam/steam.nix with the Steam Deck client fat bootstrap
#
# This allows the Steam Deck UI to start on a fresh installation
# (i.e., have not launched Steam at all before).

{ steam-original, fetchurl }:

let
  bundle = fetchurl {
    url = "https://steamdeck-packages.steamos.cloud/archlinux-mirror/sources/jupiter-main/steam-jupiter-stable-1.0.0.74-2.19.src.tar.gz";
    sha256 = "sha256-jY5gPTHQ8oLg2nqd2yNQWjVGuX4fl7uMPCpphJV4EH0=";
  };

in steam-original.overrideAttrs (old: {
  pname = "steam-jupiter-original";
  postInstall = (old.postInstall or "") + ''
    >&2 echo ":: Injecting Steam Deck client bootstrap..."
    tar xvf ${bundle}
    cp steam-jupiter-stable/steam_jupiter_stable_bootstrapped_*.tar.xz $out/lib/steam/bootstraplinux_ubuntu12_32.tar.xz
  '';
})
