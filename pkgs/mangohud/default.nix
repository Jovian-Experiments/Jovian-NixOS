{ mangohud', fetchpatch }:
# we ship a newer mangohud base, but add some backports from vendor that are still not in there
mangohud'.overrideAttrs(old: {
  patches = old.patches or [] ++ [
    (fetchpatch {
      url = "https://github.com/flightlessmango/MangoHud/commit/0805396e579c5f1ea27e2e2a78030d8ef6ce1994.diff";
      hash = "sha256-pk2ZYTjAsnGqeyk2m9nVkF6XA7bw1cSiE0I1WVuCDjM=";
    })
    (fetchpatch {
      url = "https://github.com/flightlessmango/MangoHud/commit/2c1dc5283c045e9a7e424dc913fbafcdcc7e3be1.diff";
      hash = "sha256-+EIJ5Ci0wXYIu9+p92O9RyyKFI9f9LUNB7XAA48JtPs=";
    })
  ];
})
