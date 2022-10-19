# Arbitrary known-good revision for default use.
let
  revision = "104e8082de1b20f9d0e1f05b1028795ed0e0e4bc";
in
import (builtins.fetchTarball {
  url = "https://github.com/NixOS/nixpkgs/archive/${revision}.tar.gz";
  sha256 = "sha256:1y7j4bgk6wcipy9vmfmdgy8pv1wp3mq76sdjc4yib7xdn0bvgxvh";
})
