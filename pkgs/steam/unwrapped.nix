# pkgs/games/steam/steam.nix with the Steam Deck client fat bootstrap
#
# This allows the Steam Deck UI to start on a fresh installation
# (i.e., have not launched Steam at all before).

{ steam-unwrapped', fetchurl }:

let
  bootstrapVersion = "20251031.0";
  bundle = fetchurl {
    url = "https://steamdeck-packages.steamos.cloud/misc/steam-snapshots/steam_jupiter_stable_bootstrapped_${bootstrapVersion}.tar.xz";
    hash = "sha256-A6Y7+eUV4Rwwrv8u0DilxeDBvTFHMBqzL33P+YwhCTs=";
  };
in steam-unwrapped'.overrideAttrs (old: {
  pname = "steam-jupiter-unwrapped";

  postInstall = (old.postInstall or "") + ''
    >&2 echo ":: Injecting Steam Deck client bootstrap..."
    cp ${bundle} $out/lib/steam/bootstraplinux_ubuntu12_32.tar.xz
  '';
})
