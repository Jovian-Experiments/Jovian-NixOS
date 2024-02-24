{ mesa, fetchpatch }:
mesa.overrideAttrs(old: {
  patches = old.patches ++ [
    (fetchpatch {
      url = "https://github.com/Jovian-Experiments/mesa/commit/116939e64e1bcb2b3925828ad39b49bed4ebddb4.patch";
      hash = "sha256-f8J2fUMQSHfJQI1DzflNmA4rdfe0NZQJnCU2M7d1C4o=";
    })
    (fetchpatch {
      url = "https://github.com/Jovian-Experiments/mesa/commit/572e590b089a34ad7b114488a7e39400fe47c60b.patch";
      hash = "sha256-H1SLiDKYz9fRc+mJyY65hnQiSMNc9ioOdJqkfftEQtA=";
    })
    (fetchpatch {
      url = "https://github.com/Jovian-Experiments/mesa/commit/d4fdd714b76de74698e232711e8f4e316e33fb8e.patch";
      hash = "sha256-eWPZyasZ6eqKbR23T/PePrZawyzs3K6hlzU2vnFOC44=";
    })
  ];
})
