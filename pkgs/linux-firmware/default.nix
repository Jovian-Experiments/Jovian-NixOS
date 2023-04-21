{ linux-firmware, fetchFromGitHub }:

linux-firmware.overrideAttrs(_: {
  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "linux-firmware";
    rev = "jupiter-20230420";
    hash = "sha256-ys/7G+JsiuKQo9aL5MZjs4NxqDjK2bdJkLRJaoNeIDM=";
  };

  outputHash = "sha256-eEeBS95gI7G9KVpc9boqRAdecrPc0EsfFD2nhh63fCY=";
})
