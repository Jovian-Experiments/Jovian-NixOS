#!/bin/sh
set -eu
cd "$(dirname "$(readlink -f "$0")")"

path=pkgs/tools/graphics/mangohud
tmpdir=$(mktemp -d)
trap 'rm -rf $tmpdir' EXIT

git clone https://github.com/NixOS/nixpkgs --branch=nixos-unstable --depth=1 --no-checkout --sparse "$tmpdir"
git -C "$tmpdir" sparse-checkout add "$path"
git -C "$tmpdir" checkout


rm -f upstream/*
cp -r "$tmpdir/$path/"* upstream/
