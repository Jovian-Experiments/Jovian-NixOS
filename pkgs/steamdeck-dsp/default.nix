{ stdenv
, lib
, fetchFromGitHub
, boost
, lv2
, faust2lv2
, noisetorch-ladspa
, which
, resholve
, bash
, coreutils
, dmidecode
, gnused
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
  cec-hwconfig-solution = {
    scripts = [ "share/cec-sysconf/cec-hwconfig" ];
    interpreter = "${bash}/bin/bash";
    inputs = [
      coreutils
      dmidecode
      gnused
    ];
  };
  self = stdenv.mkDerivation(finalAttrs: {
    pname = "steamdeck-dsp";
    version = "0.88";

    src = fetchFromGitHub {
      owner = "Jovian-Experiments";
      repo = "steamdeck-dsp";
      rev = finalAttrs.version;
      hash = "sha256-ba9to4/+FqxUgbVMWhbttkZ9BSw0ObFESuGRafD0B3s=";
    };

    nativeBuildInputs = [
      faust2lv2
      which
    ];

    postPatch = ''
      substituteInPlace Makefile \
        --replace-fail /usr/include/boost "${boost.dev}/include/boost" \
        --replace-fail /usr/include/lv2 "${lv2.dev}/include/lv2"

      substituteInPlace pipewire-confs/hardware-profiles/*/filter-chain.conf.d/filter-chain.conf \
        --replace-fail "/usr/lib/ladspa/rnnoise_ladspa.so" "rnnoise_ladspa"

      substituteInPlace ucm2/conf.d/*/*.conf \
        --replace-warn "exec" "# exec"

      # Fix paths
      substituteInPlace \
        pipewire-confs/hardware-profiles/pipewire-hwconfig \
        pipewire-confs/systemd/system/pipewire-sysconf.service \
        wireplumber/hardware-profiles/wireplumber-hwconfig \
        wireplumber/systemd/system/wireplumber-sysconf.service \
        cec-sysconf/systemd/system/cec-sysconf.service \
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
      ${resholve.phraseSolution "cec-hwconfig" cec-hwconfig-solution}

      # work around dead symlink
      touch $out/share/pipewire/hardware-profiles/valve-jupiter/filter-chain.conf.d/filter-chain-sink.conf
      rm -r $out/lib/systemd/system/multi-user.target.wants/

      for pkg in pipewire wireplumber; do
        for i in $(find $out/share/$pkg/hardware-profiles/* -type f -printf "%P\n" | sort | uniq); do 
          mkdir -p $(dirname "$out/share/$pkg/$i")
          ln -s /run/$pkg/$i $out/share/$pkg/$i
        done
      done
    '';

    # ¯\_(ツ)_/¯
    # Leaky wrappers I guess.
    dontWrapQtApps = true;

    passthru = {
      requiredLv2Packages = [ self ];
      requiredLadspaPackages = [ noisetorch-ladspa ];
    };

    meta = {
      description = "Steamdeck Audio Processing";
      # Actual license of all parts unclear.
      # https://github.com/Jovian-Experiments/steamdeck-dsp/blob/0.38/LICENSE
      license = lib.licenses.gpl3;
    };
  });
in self
