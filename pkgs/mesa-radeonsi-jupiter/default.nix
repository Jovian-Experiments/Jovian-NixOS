{ mesa, fetchpatch }:
mesa.overrideAttrs(old: {
  patches = old.patches ++ [
    (fetchpatch {
      url = "https://github.com/Jovian-Experiments/mesa/commit/aea11d006bfa75f2f0a56f2b7fd0046a7b4b3489.patch";
      hash = "sha256-q50+NFQjwLwsNvz4KRBoDhEo+oQ7H4QbxLDhUlSSmwc=";
    })
    (fetchpatch {
      url = "https://github.com/Jovian-Experiments/mesa/commit/00c13655e6de3b1dcdf8a6a4430b4b07d39361f8.patch";
      hash = "sha256-H1SLiDKYz9fRc+mJyY65hnQiSMNc9ioOdJqkfftEQtA=";
    })
    (fetchpatch {
      url = "https://github.com/Jovian-Experiments/mesa/commit/fda70ffc2a7b06c18062f989427bdfb9fa849d45.patch";
      hash = "sha256-eWPZyasZ6eqKbR23T/PePrZawyzs3K6hlzU2vnFOC44=";
    })
    (fetchpatch {
      url = "https://github.com/Jovian-Experiments/mesa/commit/f23c271a42da1b7bd8bc6f87aa406dfb54a6401d.patch";
      hash = "sha256-ZJ1XAhtEoutQ4EXVlsBKmF9ehWGPQ0OzOmqvE8E0a/I=";
    })
    (fetchpatch {
      url = "https://github.com/Jovian-Experiments/mesa/commit/9a26efc6b7013492eb9734bba4829c15a1dc0498.patch";
      hash = "sha256-DJUYFI9baL9Hfy1P0QeKDfH3AisP0QhUI8geE3ofHd8=";
    })
  ];
})
