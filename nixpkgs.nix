# Arbitrary known-good revision for default use.
let
  revision = "1ec61dd4167f04be8d05c45780818826132eea0d";
in
import (builtins.fetchTarball {
  url = "https://github.com/NixOS/nixpkgs/archive/${revision}.tar.gz";
  sha256 = "sha256:0aglyrxqkfwm4wxlz642vcgn0m350jv4nhhyq91cxylvs1avps54";
})
