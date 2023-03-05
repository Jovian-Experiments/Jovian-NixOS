# Arbitrary known-good revision for default use.
let
  revision = "3c5319ad3aa51551182ac82ea17ab1c6b0f0df89";
in
import (builtins.fetchTarball {
  url = "https://github.com/NixOS/nixpkgs/archive/${revision}.tar.gz";
  sha256 = "sha256:0s6vyyfmhcyqrgln304c1490spb2hqhh5bzfi0y2hnk5i5sph07q";
})
