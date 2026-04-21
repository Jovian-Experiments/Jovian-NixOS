{ lib
, stdenv
, callPackage
, xcursorgen
}:

let
  src = callPackage ./src.nix { };
in
stdenv.mkDerivation {
  pname = "steamdeck-hw-theme";

  inherit src;
  inherit (src) version;

  nativeBuildInputs = [
    xcursorgen
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share
    cp -r usr/share/icons $out/share
    cp -r usr/share/plymouth $out/share
    cp -r usr/share/holo $out/share

    sed -i "s|/usr/|$out/|g" $out/share/plymouth/themes/steamos/steamos.plymouth

    pushd $out/share/holo
    xcursorgen holo-cursor-config $out/share/icons/steam/cursors/default
    popd
  '';

  meta = with lib; {
    description = "Steam Deck themes (base)";
    license = licenses.unfreeRedistributable;
  };
}
