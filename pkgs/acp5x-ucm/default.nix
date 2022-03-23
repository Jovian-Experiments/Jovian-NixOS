{ runCommandNoCC }:

let
  version = "jupiter-20220310.1000";
in
runCommandNoCC "acp5x-ucm-${version}" {
  passthru = {
    inherit version;
  };
  meta = {
    priority = 1;
  };
} ''
  mkdir -pv $out/share/alsa/ucm2/conf.d/acp5x
  cp -rv ${./acp5x}/* $out/share/alsa/ucm2/conf.d/acp5x/

  # This *overrides the alsa-lib ucm.conf* if also linked in `pathsToLink`.
  cat > $out/share/alsa/ucm2/ucm.conf <<EOF
  Syntax 3

  UseCasePath {
      legacy {
          Directory "conf.d/acp5x"
          File "acp5x.conf"
      }
  }
  EOF
''
