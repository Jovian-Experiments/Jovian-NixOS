{ config, lib, pkgs, ... }:

let
  inherit (lib)
    concatStringsSep
    escapeShellArg
    mapAttrsToList
    mkIf
    mkMerge
    mkOption
    types
  ;

  cfg = config.jovian.steam;
in
{
  options = {
    jovian.steam = {
      environment = mkOption {
        type = with types; attrsOf str;
        default = {};
        description = ''
          Additional environment variables or overrides to environment variables
          that will be applied to the gamescope session.
        '';
      };
    };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      environment.etc."xdg/gamescope-session/environment" = {
        text = concatStringsSep "\n" (
          mapAttrsToList (
            key: value:
            "export ${escapeShellArg key}=${escapeShellArg value}"
          ) cfg.environment
        );
      };
    }
  ]);
}
