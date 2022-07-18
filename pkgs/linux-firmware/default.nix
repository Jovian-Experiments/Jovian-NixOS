{ linux-firmware, fetchFromGitHub }:

linux-firmware.overrideAttrs(_: {
  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "linux-firmware";
    rev = "jupiter-20220624";
    hash = "sha256-v4yFQAyxmyur4/XAaW0nJKaApii/dvC++Er1Fg7yjy0=";
  };

  outputHash = "sha256-7CNqA9hFqOopZjLv8DcHKMTWk0rQL8zxs7U6bbCO/TU=";
})
