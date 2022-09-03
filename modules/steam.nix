{ config, lib, pkgs, ... }:

let
  inherit (lib)
    makeBinPath
    mkDefault
    mkIf
    mkMerge
    mkOption
    mapAttrsToList
    types
  ;

  # Note that we override Steam in our overlay
  inherit (pkgs)
    gamescope
    mangohud
    systemd

    jupiter-hw-support
    steam
    steamdeck-hw-theme

    writeTextFile
    writeShellScript
    writeShellScriptBin
  ;

  cfg = config.jovian.steam;

  sessionPath = makeBinPath [
    mangohud
    systemd
    steam
    steam.run
  ];

  sessionEnvironmentArgs = builtins.concatStringsSep " " (mapAttrsToList (k: v: "--setenv=\"${k}=${v}\"") config.jovian.steam.environment);

  # Shim that runs steam and associated services.
  steam-shim = writeShellScript "steam-shim" ''
    export PATH=${sessionPath}:$PATH

    export STEAM_USE_MANGOAPP=1
    export MANGOHUD_CONFIGFILE=$(mktemp $XDG_RUNTIME_DIR/mangohud.XXXXXXXX)
    export MANGOAPP=1

    powerbuttonPath="/dev/input/by-path/platform-i8042-serio-0-event-kbd"

    # Initially write no_display to our config file
    # so we don't get mangoapp showing up before Steam initializes
    # on OOBE and stuff.
    mkdir -p "$(dirname "$MANGOHUD_CONFIGFILE")"
    echo "no_display" > "$MANGOHUD_CONFIGFILE"

    # These additional services will be culled when the main service quits too.
    # This is done by re-using the same slice name.

    systemd-run --user \
      --slice="steam-session" \
      --unit=steam-session.mangoapp \
      --property=Restart=always \
      --setenv=DISPLAY \
      --setenv=MANGOHUD_CONFIGFILE \
      -- \
      mangoapp

    if test -r "$powerbuttonPath"; then
      systemd-run --user \
        --slice="steam-session" \
        --unit=steam-session.power-button-handler \
        --property=Restart=always \
        -- \
        steam-run ${jupiter-hw-support}/lib/hwsupport/power-button-handler.py
    else
      echo ""
      echo ""
      echo "================================================================================"
      echo "[steam-session] WARNING: Power button device not readable by your user."
      echo "                         Add $USER to the input group to have complete support"
      echo "                         for the Steam Deck's power menu."
      echo "================================================================================"
      echo ""
      echo ""
    fi

    exec steam -steamos3 -steampal -steamdeck -gamepadui "$@"
  '';

  # Shim that runs gamescope, with a specific environment.
  # NOTE: This is only used to provide gamescope_pid.
  gamescope-shim = writeShellScript "gamescope-shim" ''
    # We will `exec` and thus replace the current process with
    # gamescope, which will in turn have the current PID.
    export gamescope_pid="''$$"
    # gamescope_pid is used by the `steamos-session-select` script.
    # TODO[Jovian]: Explore other ways to stop the session?
    #               -> `systemctl --user stop steam-session.slice`?

    exec ${gamescope}/bin/gamescope "$@"
  '';

  # TODO: consume width/height script input params
  # TODO: consume script input param to disable fullscreening
  # TODO: pass down unhandled arguments
  # Script that launches the gamescope shim within a systemd scope.
  steam-session = writeShellScriptBin "steam-session" ''
    SLICE="steam-session"

    runtime_dir="$XDG_RUNTIME_DIR/$SLICE.run"
    mkdir -p "$runtime_dir"
    export GAMESCOPE_STATS="$runtime_dir/stats.pipe"
    rm -f "$GAMESCOPE_STATS"
    mkfifo -- "$GAMESCOPE_STATS"

    # To play nice with the short term callback-based limiter for now
    export GAMESCOPE_LIMITER_FILE=$(mktemp $runtime_dir/gamescope-limiter.XXXXXXXX)

    # Prepare our initial VRS config file
    # for dynamic VRS in Mesa.
    export RADV_FORCE_VRS_CONFIG_FILE=$(mktemp $runtime_dir/radv_vrs.XXXXXXXX)
    echo "1x1" > "$RADV_FORCE_VRS_CONFIG_FILE"

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
      --cursor ${steamdeck-hw-theme}/share/steamos/steamos-cursor.png
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

    systemd-run --user --scope --slice="$SLICE" ${sessionEnvironmentArgs} -- "''${gamescope_incantation[@]}"
  '';

  steam-session-desktop = (writeTextFile {
    name = "steam-session-desktop";
    destination = "/share/wayland-sessions/steam-wayland.desktop";
    text = ''
      [Desktop Entry]
      Encoding=UTF-8
      Name=Gaming Mode
      Exec=${steam-session}/bin/steam-session
      Icon=steamicon.png
      Type=Application
      DesktopNames=gamescope
    '';
  }) // {
    providedSessions = [ "steam-wayland" ];
  };
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

        environment = mkOption {
          type = types.attrsOf types.str;
          default = {};
          description = ''
            Environment variables to set for Steam.
          '';
        };

        useStockEnvironment = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Whether to use the stock environment variables from gamescope-session.
          '';
        };

        useStockSteamDeckEnvironment = mkOption {
          type = types.bool;
          default = config.jovian.devices.steamdeck.enable;
          description = ''
            Whether to use the Steam Deck-specific environment variables from stock gamescope-session.
          '';
        };
      };
    };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      hardware.opengl.driSupport32Bit = true;
      hardware.pulseaudio.support32Bit = true;

      environment.systemPackages = [ steam-session ];

      services.xserver.displayManager.sessionPackages = [ steam-session-desktop ];

      # Conflicts with power-button-handler
      services.logind.extraConfig = ''
        HandlePowerKey=ignore
      '';
    }
    (mkIf cfg.useStockEnvironment {
      jovian.steam.environment = {
        # Set input method modules for Qt/GTK that will show the Steam keyboard
        QT_IM_MODULE = "steam";
        GTK_IM_MODULE = "Steam";

        # Enable volume key management via steam for this session
        STEAM_ENABLE_VOLUME_HANDLER = "1";

        # Have SteamRT's xdg-open send http:// and https:// URLs to Steam
        SRT_URLOPEN_PREFER_STEAM = "1";

        # Disable automatic audio device switching in steam, now handled by wireplumber
        STEAM_DISABLE_AUDIO_DEVICE_SWITCHING = "1";

        # Enable support for xwayland isolation per-game in Steam
        STEAM_MULTIPLE_XWAYLANDS = "1";

        # We have the Mesa integration for the fifo-based dynamic fps-limiter
        STEAM_GAMESCOPE_DYNAMIC_FPSLIMITER = "1";

        # We have gamma/degamma exponent support
        STEAM_GAMESCOPE_COLOR_TOYS = "1";

        # We have NIS support
        STEAM_GAMESCOPE_NIS_SUPPORTED = "1";

        # Set refresh rate range and enable refresh rate switching
        STEAM_DISPLAY_REFRESH_LIMITS = "40,60";

        STEAM_USE_DYNAMIC_VRS = "1";

        STEAM_UPDATEUI_PNG_BACKGROUND = "${steamdeck-hw-theme}/share/steamos/steamos.png";

        # Don't wait for buffers to idle on the client side before sending them to gamescope
        vk_xwayland_wait_ready = "false";

        # There is no way to set a color space for an NV12
        # buffer in Wayland. And the color management protocol that is
        # meant to let this happen is missing the color range...
        # So just workaround this with an ENV var that Remote Play Together
        # and Gamescope will use for now.
        GAMESCOPE_NV12_COLORSPACE = "k_EStreamColorspace_BT601";

        # To expose vram info from radv's patch we're including
        WINEDLLOVERRIDES = "dxgi=n";

        XCURSOR_THEME = "steam";

        SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS = "0";
      };
    })
    (mkIf cfg.useStockSteamDeckEnvironment {
      jovian.steam.environment = {
        # Enable dynamic backlight, we have the kernel patch to disable events
        STEAM_ENABLE_DYNAMIC_BACKLIGHT = "1";

        # Let's try this across the board to see if it breaks anything
        # Helps performance in HZD, Cyberpunk, at least
        # Expose 8 physical cores, instead of 4c/8t
        WINE_CPU_TOPOLOGY = "8:0,1,2,3,4,5,6,7";
      };
    })
  ]);
}
