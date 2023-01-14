{ linux-firmware, fetchFromGitHub }:

linux-firmware.overrideAttrs(_: {
  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "linux-firmware";
    rev = "jupiter-20230110";
    hash = "sha256-XHdqeWYYlobqCr53wc9GvBiMpzzOgEP785R5YhoCIwI=";
  };

  outputHash = "sha256-v66fhA2WdYgrOLxEC6IHA6wDv9T5vLJV81DJq/sbMA0=";
})
