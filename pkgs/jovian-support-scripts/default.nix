{ stdenv
, resholve

, bash
, jq
, systemd
, util-linux
}:

let
  solution = {
    scripts = [ "bin/steamos-polkit-helpers/*" ];
    interpreter = "${bash}/bin/bash";
    inputs = [
      jq
      systemd
      util-linux
    ];
    keep = {
      "${placeholder "out"}/bin/steamos-polkit-helpers/steamos-format-device" = true;
    };
  };
in
stdenv.mkDerivation {
  name = "jovian-support-scripts";

  buildCommand = ''
    install -D -m 755 ${./steamos-format-sdcard} $out/bin/steamos-format-sdcard
    install -D -m 755 ${./steamos-format-device} $out/bin/steamos-format-device

    substituteInPlace $out/bin/steamos-format-sdcard \
      --replace-fail "/usr/bin/steamos-polkit-helpers/steamos-format-device" "$out/bin/steamos-polkit-helpers/steamos-format-device"
    (
    cd $out/bin

    mkdir -v steamos-polkit-helpers
    cd steamos-polkit-helpers
    ln -v -t . ../steamos-format-*
    )

    ${resholve.phraseSolution "steamos-format-sdcard" solution}
    ${resholve.phraseSolution "steamos-format-device" solution}
  '';

  meta = {
    # Any script defined here should be prioritized over Steam's own.
    priority = -10;
  };
}
