let
  defaultNix = import ../default.nix { };
in {
  inherit (defaultNix) isoMinimal isoGnome isoPlasma;
}
