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
  '';

  # ¯\_(ツ)_/¯
  # Leaky wrappers I guess.
  dontWrapQtApps = true;

  meta = {
    description = "Steamdeck Audio Processing";
    # Actual license of all parts unclear.
    # https://github.com/Jovian-Experiments/steamdeck-dsp/blob/0.38/LICENSE
    license = lib.licenses.gpl3;
  };
})
