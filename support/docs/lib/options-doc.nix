{ lib
, nixosOptionsDoc
}:

# Given an options tree (or subset thereof) generates the documentation for it.
# See `<nixpkgs/nixos/lib/make-options-doc/default.nix>` for the output details.
{ options
, prefix
, sourceLinkPrefix ? "https://github.com/Jovian-Experiments/Jovian-NixOS/blob/development"
}:

nixosOptionsDoc {
  inherit options;

  # Adapted from nixpkgs/nixos/doc/manual/default.nix
  transformOptions = opt: opt // {
    declarations = map (decl:
      if lib.hasPrefix (toString prefix) (toString decl)
      then
        let
          subpath = lib.removePrefix "/" (lib.removePrefix (toString prefix) (toString decl));
        in
        { url = "${sourceLinkPrefix}/${subpath}"; name = subpath; }
      else decl
    ) opt.declarations;
  };
}
