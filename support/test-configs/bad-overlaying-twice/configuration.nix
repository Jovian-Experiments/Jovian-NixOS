{
  imports = [
    ../../../modules
  ];

  # WARNING: Never import the overlay in this way.
  #          The modules handles importing the overlay already.
  #          See: https://github.com/Jovian-Experiments/Jovian-NixOS/issues/486
  nixpkgs.overlays = [
    # This overlay.nix file is not a public interface.
    (import ../../../overlay.nix)
  ];
}
