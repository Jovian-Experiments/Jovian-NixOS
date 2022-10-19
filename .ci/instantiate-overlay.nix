let
  overlay = import ../overlay.nix;
  overlayContents = builtins.attrNames (overlay {} {}) ++ [ "steam" ];

  pkgs = import ../nixpkgs.nix {
    config.allowUnfree = true;
    overlays = [ overlay ];
  };

  inherit (pkgs) lib;
in builtins.listToAttrs (map (x: lib.nameValuePair x pkgs.${x}) overlayContents)
