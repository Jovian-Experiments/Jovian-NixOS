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
in stdenv.mkDerivation(finalAttrs: {
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

    >&2 echo "Checking configuration files"

    echo -e "${builtins.concatStringsSep "\n" finalAttrs.passthru.filesInstalledToEtc}" \
      | sort >etc.expected.txt

    for dir in wireplumber pipewire; do
      find $out/share/$dir -type f -printf "$dir/%P\n"
    done | grep -v wireplumber/hardware-profiles | sort >etc.actual.txt

    if ! cmp --silent etc.{expected,actual}.txt; then
      >&2 echo "!! passthru.filesInstalledToEtc needs to be updated. The actual list of config files:"
      cat etc.actual.txt
      false
    fi

    echo -e "${builtins.concatStringsSep "\n" finalAttrs.passthru.filesInstalledToRun}" \
      | sort >run.expected.txt

    for dir in valve-galileo valve-jupiter; do
      find $out/share/wireplumber/hardware-profiles/$dir -type f -printf "%P\n"
    done | sort | uniq >run.actual.txt

    if ! cmp --silent run.{expected,actual}.txt; then
      >&2 echo "!! passthru.filesInstalledToRun needs to be updated. The actual list of config files:"
      cat run.actual.txt
      false
    fi
  '';

  # ¯\_(ツ)_/¯
  # Leaky wrappers I guess.
  dontWrapQtApps = true;

  passthru = {
    filesInstalledToEtc = [
      "pipewire/pipewire.conf.d/filter-chain-sink.conf"
      "pipewire/pipewire.conf.d/filter-chain.conf"
      "pipewire/pipewire.conf.d/virtual-sink.conf"
      "pipewire/pipewire.conf.d/virtual-source.conf"
      "wireplumber/main.lua.d/60-alsa-acp5x-config.lua"
      "wireplumber/main.lua.d/60-alsa-card0-config.lua"
      "wireplumber/main.lua.d/60-alsa-ps-controller-config.lua"
      "wireplumber/scripts/open-alsa-acp-dsm-node.lua"
    ];
    filesInstalledToRun = [
      "bluetooth.lua.d/60-bluez.lua"
    ];
  };

  meta = {
    description = "Steamdeck Audio Processing";
    # Actual license of all parts unclear.
    # https://github.com/Jovian-Experiments/steamdeck-dsp/blob/0.38/LICENSE
    license = lib.licenses.gpl3;
  };
})
