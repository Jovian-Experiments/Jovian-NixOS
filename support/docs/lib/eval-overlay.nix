{ lib
}:

# This does two things:
#
#  - Gets the new / edited attributes from the overlay.
#  - Provide an attrset with those names only, from the given `pkgs`.
#
# This requires `pkgs` to have the given overlay applied.
{ path, pkgs }:

let
  inherit (lib)
    mapAttrs
  ;
  # NOTE: we will not actively evaluate the overlay attribute values.
  almostOverlay = (import path) pkgs pkgs;
in
mapAttrs (
  name: _:
  # Pick the already applied values
  pkgs."${name}"
) almostOverlay
