{ linux-firmware, fetchFromGitHub }:

linux-firmware.overrideAttrs(_: {
  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "linux-firmware";
    rev = "jupiter-20211216";
    hash = "sha256-kbEMWE29/gqQdyIhE39UNhqWyr02AHhsL05l9vwpzrk=";
  };

  outputHash = "sha256-Up+1AOEg4ydROtQ9vwR0J62v/o8Ry5kH4Uoy2iand7k=";
})
