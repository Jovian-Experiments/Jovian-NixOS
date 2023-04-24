# Arbitrary known-good revision for default use.
let
  revision = "e78d25df6f1036b3fa76750ed4603dd9d5fe90fc";
in
import (builtins.fetchTarball {
  url = "https://github.com/NixOS/nixpkgs/archive/${revision}.tar.gz";
  sha256 = "sha256:1fgq4kvk88klmk4vrs2y0ml9ff34avk7a8mzk47nw3v7r246prnr";
})
