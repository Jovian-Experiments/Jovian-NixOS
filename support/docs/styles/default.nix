{ stdenv
, runCommandLocal
, writeShellScriptBin
, nodePackages
}:

let
  embedSVG = writeShellScriptBin "embed-svg" ''
    in=$1
    out=$2

    mkdir -p $in.tmp

    cp $in/*.svg $in.tmp/
    rm -f $in.tmp/*.src.svg

    echo ":: Optimizing svg files"
    for f in $in.tmp/*.svg; do
      echo "::  - $f"
      ${nodePackages.svgo}/bin/svgo $f &
    done
    # Wait until all `svgo` processes are done
    # According to light testing, it is twice as fast that way.
    wait

    echo ":: Embedding SVG files"
    source ${stdenv}/setup # for substituteInPlace
    ls -la $in
    cp $in/svg.less $out
    for f in $in.tmp/*.svg; do
      echo "::  - $f"
      token=$(basename $f)
      token=''${token^^}
      token=''${token//[^A-Z0-9]/_}
      token=SVG_''${token/%_SVG/}
      echo "::    $token"
      substituteInPlace $out --replace "@$token)" "'$(cat $f)')"
      substituteInPlace $out --replace "@$token," "'$(cat $f)',"
    done

    rm -rf $in.tmp
  '';

  embedded-svg = runCommandLocal "embedded-svg.less" {
    nativeBuildInputs = [
      embedSVG
    ];
    src = ./assets;
  } ''
    echo $src
    mkdir -p ./assets
    cp $src/* ./assets
    chmod -R +w ./assets
    embed-svg ./assets $out
  '';

  styles = stdenv.mkDerivation {
    name = "jovian-nixos-docs-styles";

    src = ./.;

    preferLocalBuild = true;
    enableParallelBuilding = true;

    buildInputs = [
      embedSVG
      nodePackages.less
    ];

    installPhase = ''
      mv -v assets _assets
      mkdir -v assets
      cp -vf ${embedded-svg} assets/svg.less
      cp -t assets _assets/*.png
      cp -t assets _assets/*.jp*g

      mkdir -p $out

      lessc \
        --math=always \
        --verbose \
        --compress \
        index.less $out/index.css

      mkdir -vp $out/fonts
      cp -t $out/fonts common/fonts/*.ttf
    '';
  };
in
  styles
