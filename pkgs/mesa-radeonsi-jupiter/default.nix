{ mesa, fetchpatch }:
mesa.overrideAttrs(old: {
  patches = old.patches ++ [
    # Our Mesa is 24.1, so cherry-pick the swapchain override bits from the Valve 24.1 branch
    (fetchpatch {
      url = "https://github.com/Jovian-Experiments/mesa/commit/d0722142079fdc5dab999aca9456cab6b8a9a214.patch";
      hash = "sha256-oayXr+BjgO47yZM1IXnpykDTNirqZBW75nN/wsRzNGw=";
    })
  ];
})
