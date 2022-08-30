{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkDefault
    mkIf
    mkMerge
    mkOption
    types
  ;

  inherit (pkgs.steam-session)
    steam
  ;

  # TODO: provide generic helper (submodule?) to use a similar gamescope setup for other uses (e.g. kodi, retroarch, ppsspp)

  # TODO: add all environment variables affecting steam here
  # TODO: systemd-run with `--property=Restart=always` for power-button helper and mangoapp
  # Shim that runs steam and associated services.
  steam-shim = pkgs.writeShellScript "steam-shim" ''
    export STEAM_USE_MANGOAPP=1
    export MANGOHUD_CONFIGFILE=$(mktemp $XDG_RUNTIME_DIR/mangohud.XXXXXXXX)
    export MANGOAPP=1

    # Initially write no_display to our config file
    # so we don't get mangoapp showing up before Steam initializes
    # on OOBE and stuff.
    mkdir -p "$(dirname "$MANGOHUD_CONFIGFILE")"
    echo "no_display" > "$MANGOHUD_CONFIGFILE"

    # These additional services will be culled when the main service quits too.
    mangoapp &
    ${steam.run}/bin/steam-run ${pkgs.jupiter-hw-support}/lib/hwsupport/power-button-handler.py &

    exec ${steam}/bin/steam -steamos3 -steampal -steamdeck -gamepadui "$@"
  '';

  # Shim that runs gamescope, with a specific environment.
  # NOTE: This is only used to provide gamescope_pid.
  gamescope-shim = pkgs.writeShellScript "gamescope-shim" ''
    # We will `exec` and thus replace the current process with
    # gamescope, which will in turn have the current PID.
    export gamescope_pid="''$$"
    # gamescope_pid is used by the `steamos-session-select` script.
    # TODO[Jovian]: Explore other ways to stop the session?
    #               -> `systemctl --user stop steam-session.slice`?

    exec ${pkgs.gamescope}/bin/gamescope "$@"
  '';

  # TODO: consume width/height script input params
  # TODO: consume script input param to disable fullscreening
  # TODO: pass down unhandled arguments
  # TODO: add environment variables affecting gamescope here
  # Script that launches the gamescope shim within a systemd scope.
  jovian-steam-session = pkgs.writeShellScriptBin "steam-session" ''
    SLICE="steam-session"

    runtime_dir="$XDG_RUNTIME_DIR/$SLICE.run"
    mkdir -p "$runtime_dir"
    export GAMESCOPE_STATS="$runtime_dir/stats.pipe"
    rm -f "$GAMESCOPE_STATS"
    mkfifo -- "$GAMESCOPE_STATS"

    gamescope_incantation=(
      "${gamescope-shim}"

      # Steam intrinsically knows it can use one of the layer for the
      # game, and the other for its overlay UI.
      # TODO[Jovian]: verify assertion
      --xwayland-count 2

      -w 1280 -h 800

      --fullscreen

      # TODO[Jovian]: document why '*' here
      --prefer-output '*',eDP-1
      --generate-drm-mode fixed
      --max-scale 2

      --default-touch-mode 4

      --hide-cursor-delay 3000
      --fade-out-duration 200
      # TODO[Jovian]: Provide our own cursor for FOSS steam-less gamescope
      #               -> adwaita or similar
      --cursor ${pkgs.steamdeck-hw-theme}/share/steamos/steamos-cursor.png
      --cursor-hotspot 5,3

      # TODO[Jovian]: only add when running steam
      --steam

      # Steam uses this
      # TODO[Jovian]: document how it's used?
      --stats-path "$GAMESCOPE_STATS"

      # Not needed when executing steam as a child process
      # --ready-fd "$socket"

      --

      "${steam-shim}" "$@"
    )

    at_exit() {
      systemctl --quiet --user stop "$SLICE.slice"
    }
    trap at_exit SIGINT SIGTERM EXIT

    PS4=" [steam-session] $ "
    set -x

    systemd-run --user --scope --slice="$SLICE" -- "''${gamescope_incantation[@]}"
  '';
in
{
  options = {
    jovian = {
      steam = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Whether to enable the Steam Deck UI.

            When enabled, you can either launch the Steam Deck UI
            from your Display Manager or by running `steam-session`.
          '';
        };
      };
    };
  };
  config = mkMerge [
    (mkIf config.jovian.steam.enable {
      hardware.opengl.driSupport32Bit = true;
      hardware.pulseaudio.support32Bit = true;

      environment.systemPackages = [ jovian-steam-session ];

      # FIXME: pack back into a proper session package
      #services.xserver.displayManager.sessionPackages = [ pkgs.steam-session ];

      # Conflicts with power-button-handler
      services.logind.extraConfig = ''
        HandlePowerKey=ignore
      '';
    })
  ];
}
