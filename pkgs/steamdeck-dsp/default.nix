{ stdenv
, lib
, fetchFromGitHub
, boost
, lv2
, faust2lv2
, rnnoise-plugin
, which
}:

stdenv.mkDerivation(finalAttrs: {
  pname = "steamdeck-dsp";
  version = "0.39";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "steamdeck-dsp";
    rev = finalAttrs.version;
    sha256 = "sha256-t/Px0PpTrzZIpxii8J5jD141uLpMKvrnZRxZODPMK+I=";
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
  '';

  preInstall = ''
    export DEST_DIR="$out"
  '';

  postInstall = ''
    mv -vt $out $out/usr/*
    rmdir -v $out/usr

    >&2 echo "Checking configuration files"

    echo -e "${builtins.concatStringsSep "\n" finalAttrs.passthru.filesInstalledToEtc}" \
      | sort >etc.expected.txt

    for dir in wireplumber pipewire; do
      find $out/share/$dir -type f -printf "$dir/%P\n"
    done | sort >etc.actual.txt

    if ! cmp --silent etc.{expected,actual}.txt; then
      >&2 echo "!! passthru.filesInstalledToEtc needs to be updated. The actual list of config files:"
      cat etc.actual.txt
      false
    fi
  '';

  # ¯\_(ツ)_/¯
  # Leaky wrappers I guess.
  dontWrapQtApps = true;

  passthru.filesInstalledToEtc = [
    "pipewire/pipewire.conf.d/filter-chain-sink.conf"
    "pipewire/pipewire.conf.d/filter-chain.conf"
    "pipewire/pipewire.conf.d/virtual-sink.conf"
    "pipewire/pipewire.conf.d/virtual-source.conf"
    "wireplumber/bluetooth.lua.d/60-bluez-jupiter.lua"
    "wireplumber/main.lua.d/60-alsa-acp5x-config.lua"
    "wireplumber/main.lua.d/60-alsa-card0-config.lua"
    "wireplumber/main.lua.d/60-alsa-ps-controller-config.lua"
    "wireplumber/scripts/open-alsa-acp-dsm-node.lua"
  ];

  meta = {
    description = "Steamdeck Audio Processing";
    # Actual license of all parts unclear.
    # https://github.com/Jovian-Experiments/steamdeck-dsp/blob/0.38/LICENSE
    license = lib.licenses.gpl3;
  };
})
