{ lib
, writeTextFile
, pkgs
}:

let
  pkgsPath = pkgs.path;
in

{ overlay
, prefix
, sourceLinkPrefix ? "https://github.com/Jovian-Experiments/Jovian-NixOS/blob/development"
}:

let
  inherit (lib)
    getName
    getVersion
    head
    isDerivation
    mapAttrs
    optionalAttrs
    splitString
    last
  ;
  documentDerivation =
    drv:
    let
      toNixpkgsRelative =
        decl:
        if lib.hasPrefix (toString pkgsPath) (toString decl)
        then "<nixpkgs/${lib.removePrefix "/" (lib.removePrefix (toString pkgsPath) (toString decl))}>"
        else "(...)"
      ;
      toRelative =
        decl:
        if lib.hasPrefix (toString prefix) (toString decl)
        then lib.removePrefix "/" (lib.removePrefix (toString prefix) (toString decl))
        else (toNixpkgsRelative decl)
      ;
      url =
        if position == null || lib.hasPrefix "<nixpkgs" position
        then null
        else let
          subpath = head (splitString ":" position);
          lineno = last (splitString ":" position);
        in "${sourceLinkPrefix}/${subpath}#L${lineno}"
      ;
      position = if drv.meta ? "position" 
                 then toRelative drv.meta.position
                 else null;
    in
    {
      entry_type = "package";
      inherit
        position
        url
      ;
      inherit (drv)
        outputs
        outputName
      ;
    }
    // (if drv ? pname then { inherit (drv) pname; } else { pname = getName drv; })
    // (if drv ? version then { inherit (drv) version; } else { version = getVersion drv; })
    // optionalAttrs (drv ? meta.description)      { inherit (drv.meta) description; }
    // optionalAttrs (drv ? meta.longDescription)  { inherit (drv.meta) longDescription; }
    // optionalAttrs (drv ? meta.license)          { inherit (drv.meta) license; }
  ;
  overlayData =
    mapAttrs (
      _: entry:
      if isDerivation entry
      then
        documentDerivation entry
      else
      {
        entry_type = "skip";
        reason = "(Entry is not a derivation...)";
      }
    ) overlay
  ;
in

{
  overlayJSON = writeTextFile {
    name = "overlay-doc";
    destination = "/overlay.json";
    text = builtins.toJSON overlayData;
  };
}
