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
  pipewire-hwconfig-solution = {
    scripts = [ "share/pipewire/hardware-profiles/pipewire-hwconfig" ];
    interpreter = "${bash}/bin/bash";
    inputs = [
      coreutils
      dmidecode
    ];
  };
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
    version = "0.49.5";

    src = fetchFromGitHub {
      owner = "Jovian-Experiments";
      repo = "steamdeck-dsp";
      rev = finalAttrs.version;
      hash = "sha256-RleDIa1E3kOCYlOdzNSfk4u0Cb4NhzP4GIJjjD6CeMA=";
    };

    nativeBuildInputs = [
      faust2lv2
      which
    ];

    postPatch = ''
      substituteInPlace Makefile \
        --replace-fail /usr/include/boost "${boost.dev}/include/boost" \
        --replace-fail /usr/include/lv2 "${lv2.dev}/include/lv2"

      substituteInPlace pipewire-confs/hardware-profiles/valve-{jupiter,galileo}/pipewire.conf.d/filter-chain.conf \
        --replace-fail "/usr/lib/ladspa/librnnoise_ladspa.so" "${rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so"

      substituteInPlace ucm2/conf.d/*/*.conf \
        --replace-warn "exec" "# exec"

      # Fix paths
      substituteInPlace \
        pipewire-confs/hardware-profiles/pipewire-hwconfig \
        pipewire-confs/systemd/system/pipewire-sysconf.service \
        wireplumber/hardware-profiles/wireplumber-hwconfig \
        wireplumber/systemd/system/wireplumber-sysconf.service \
        --replace-fail "/usr/share" "$out/share"
    '';

    preInstall = ''
      export DEST_DIR="$out"
    '';

    postInstall = ''
      mv -vt $out $out/usr/*
      rmdir -v $out/usr

      ${resholve.phraseSolution "pipewire-hwconfig" pipewire-hwconfig-solution}
      ${resholve.phraseSolution "wireplumber-hwconfig" wireplumber-hwconfig-solution}

      for pkg in pipewire wireplumber; do
        for i in $(find $out/share/$pkg/hardware-profiles/{valve-jupiter,valve-galileo} -type f -printf "%P\n" | sort | uniq); do 
          mkdir -p $(dirname "$out/share/$pkg/$i")
          ln -s /run/$pkg/$i $out/share/$pkg/$i
        done
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
