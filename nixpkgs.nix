# Arbitrary known-good revision for default use.
let
  revision = "0591d6b57bfeb55dfeec99a671843337bc2c3323";
in
import (builtins.fetchTarball {
  url = "https://github.com/NixOS/nixpkgs/archive/${revision}.tar.gz";
  sha256 = "sha256:14b02qjbcb8cgfy7hldk45zd8agsqvfccfhs4bq0yk1rqd0ixd2d";
})
