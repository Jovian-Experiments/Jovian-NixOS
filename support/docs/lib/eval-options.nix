{ lib
, nixos
}:

# Given a directory path, evaluates the options in combination with NixOS options.
{ path }:
let
  suppressModuleArgsDocs = { lib, ... }: {
    options = {
      _module.args = lib.mkOption {
        internal = true;
      };
    };
  };
  eval = nixos {
    imports = [
      path
      suppressModuleArgsDocs
    ];
  };
in eval.options
