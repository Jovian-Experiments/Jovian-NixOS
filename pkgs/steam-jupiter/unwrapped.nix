# pkgs/games/steam/steam.nix with the Steam Deck client fat bootstrap
#
# This allows the Steam Deck UI to start on a fresh installation
# (i.e., have not launched Steam at all before).

{ steam-unwrapped, fetchurl }:

let
  bootstrapVersion = "1.0.0.81-2.2";
  bundle = fetchurl {
    url = "https://steamdeck-packages.steamos.cloud/archlinux-mirror/sources/jupiter-main/steam-jupiter-stable-${bootstrapVersion}.src.tar.gz";
    hash = "sha256-PAA1fV7JZSv07cXewtAjwD96gUwuAde2P+Pg+bGQkPY=";
  };
in steam-unwrapped.overrideAttrs (old: {
  pname = "steam-jupiter-unwrapped";

  postInstall = (old.postInstall or "") + ''
    >&2 echo ":: Injecting Steam Deck client bootstrap..."
    tar xvf ${bundle}
    cp steam-jupiter-stable/steam_jupiter_stable_bootstrapped_*.tar.xz $out/lib/steam/bootstraplinux_ubuntu12_32.tar.xz
  '';
})
