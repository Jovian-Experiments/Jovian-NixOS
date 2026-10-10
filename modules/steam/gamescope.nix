{ config, lib, ... }:

let
  inherit (lib)
    concatStringsSep
    mkIf
    mkOption
    optionals
    toShellVar
    types
  ;

  cfg = config.jovian.steam;
in
{
  options = {
    jovian.steam.gamescope = {
      preferOutputs = mkOption {
        type = types.listOf types.str;
        default = [ "*" "eDP-1" ];
        description = ''
          List of preferred outputs (monitors) for gamescope. gamescope will
          start on the *first* matching monitor.

          The default is to prefer *any* monitor that is not the internal
          Steam Deck display (`eDP-1`).

          You can find the set of available outputs using tools like `xrandr` (X11)
          or `wlr-randr` (Wayland).
        '';
        example = [ "HDMI-1" "DP-2" ];
      };
      extraArgs = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          Additional arguments to pass as-is to the gamescope instance as flags.

          You can find the full set of available flags by running:

          ```shell
          $ gamescope --help
          ```
        '';
        example = [ "--mangoapp" "-r" "120" ];
      };
    };
  };

  config = mkIf cfg.enable {
    environment.etc."xdg/gamescope-session/environment" = {
      text = let
        args = (optionals (cfg.gamescope.preferOutputs != []) [
          "-O" (concatStringsSep "," cfg.gamescope.preferOutputs)
        ]) ++ cfg.gamescope.extraArgs;
      in lib.mkAfter (toShellVar "JOVIAN_GAMESCOPE_ARGS" args);
    };
  };
}
