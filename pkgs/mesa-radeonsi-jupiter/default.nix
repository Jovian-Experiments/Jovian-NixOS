{ mesa, fetchpatch }:
# Patches from mesa-24.0..radeonsi-24.0.4, minus things merged in Mesa upstream
mesa.overrideAttrs(old: {
  patches = old.patches ++ [
    # Cherry-pick the swapchain override bits from the Valve 24.1 branch
    (fetchpatch {
      url = "https://github.com/Jovian-Experiments/mesa/commit/d0722142079fdc5dab999aca9456cab6b8a9a214.patch";
      hash = "sha256-oayXr+BjgO47yZM1IXnpykDTNirqZBW75nN/wsRzNGw=";
    })
    # Disable glthread by default
    (fetchpatch {
      url = "https://github.com/Jovian-Experiments/mesa/commit/09d9c2fd7f69fbe59aab0bb53438d3446ea90dd4.patch";
      hash = "sha256-y0wGWVBQiWd2hOqiqDIKP9VERNSP4owuPGjnqUTNy68=";
    })
    # Backport HEVC encode fix
    (fetchpatch {
      url = "https://github.com/Jovian-Experiments/mesa/commit/6c30d44613d5945c0660701a5a59c659a709ca37.patch";
      hash = "sha256-pl1gU6aMUupFAf4vxDffzpyZ3Lz6SzVYeAtLuulLWcU=";
    })
  ];
})
