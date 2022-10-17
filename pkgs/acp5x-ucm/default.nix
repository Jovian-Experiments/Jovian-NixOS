{ runCommand }:

let
  version = "jupiter-20220310.1000";
in
runCommand "acp5x-ucm-${version}" {
  passthru = {
    inherit version;
  };
  meta = {
    priority = 1;
  };
} ''
  mkdir -pv $out/share/alsa/ucm2/conf.d/acp5x
  cp -rv ${./acp5x}/* $out/share/alsa/ucm2/conf.d/acp5x/

  # Temporary workaround for https://github.com/alsa-project/alsa-lib/pull/249
  # Fixed in alsa-lib 1.2.7.2
  mv $out/share/alsa/ucm2/conf.d/acp5x/acp5x.conf{,.real}
  # not using the absolute path as the target is intentional - it's otherwise broken :/
  ln -s acp5x.conf.real $out/share/alsa/ucm2/conf.d/acp5x/acp5x.conf

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
