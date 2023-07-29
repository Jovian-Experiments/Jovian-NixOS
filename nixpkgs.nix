# Arbitrary known-good revision for default use.
let
  lock = builtins.fromJSON (builtins.readFile ./flake.lock);
in
import (builtins.fetchTarball {
  url = "https://github.com/NixOS/nixpkgs/archive/${lock.nodes.nixpkgs.locked.rev}.tar.gz";
  sha256 = lock.nodes.nixpkgs.locked.narHash;
})
