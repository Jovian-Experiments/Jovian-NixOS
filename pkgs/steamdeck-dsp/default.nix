{ stdenv
, lib
, fetchFromGitHub
, boost
, lv2
, faust2lv2
, rnnoise-plugin
, which
, resholve
, bash
, coreutils
, dmidecode
}:

let
  wireplumber-hwconfig-solution = {
    scripts = [ "share/wireplumber/hardware-profiles/wireplumber-hwconfig" ];
    interpreter = "${bash}/bin/bash";
    inputs = [
      coreutils
      dmidecode
    ];
  };
  self = stdenv.mkDerivation(finalAttrs: {
    pname = "steamdeck-dsp";
    version = "0.42";

    src = fetchFromGitHub {
      owner = "Jovian-Experiments";
      repo = "steamdeck-dsp";
      rev = finalAttrs.version;
      hash = "sha256-A0O6whz6S/izYv9dMORjYTlpg8LwKKFyXw0CTHPIi/s=";
    };

    nativeBuildInputs = [
      faust2lv2
      which
    ];

    postPatch = ''
      substituteInPlace Makefile \
        --replace /usr/include/boost "${boost.dev}/include/boost" \
        --replace /usr/include/lv2 "${lv2.dev}/include/lv2"

      substituteInPlace pipewire-confs/filter-chain-mic.conf \
        --replace "/usr/lib/ladspa/librnnoise_ladspa.so" "${rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so"

      # Stop trying to run `echo`, we don't have it
      substituteInPlace ucm2/conf.d/*/*.conf \
        --replace "exec" "# exec"

      # Fix paths
      substituteInPlace wireplumber/hardware-profiles/wireplumber-hwconfig \
        --replace "/usr/share" "$out/share"

      substituteInPlace wireplumber/systemd/system/wireplumber-sysconf.service \
        --replace "/usr/share" "$out/share"
    '';

    preInstall = ''
      export DEST_DIR="$out"
    '';

    postInstall = ''
      mv -vt $out $out/usr/*
      rmdir -v $out/usr

      ${resholve.phraseSolution "wireplumber-hwconfig" wireplumber-hwconfig-solution}

      for i in $(find $out/share/wireplumber/hardware-profiles/{valve-jupiter,valve-galileo} -type f -printf "%P\n" | sort | uniq); do 
        mkdir -p $(dirname "$out/share/wireplumber/$i")
        ln -s /run/wireplumber/$i $out/share/wireplumber/$i
      done
    '';

    # ¯\_(ツ)_/¯
    # Leaky wrappers I guess.
    dontWrapQtApps = true;

    passthru.requiredLv2Packages = [ self ];

    meta = {
      description = "Steamdeck Audio Processing";
      # Actual license of all parts unclear.
      # https://github.com/Jovian-Experiments/steamdeck-dsp/blob/0.38/LICENSE
      license = lib.licenses.gpl3;
    };
  });
in self
