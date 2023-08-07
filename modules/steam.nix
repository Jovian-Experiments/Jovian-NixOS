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
    bubblewrap
    systemd

    jupiter-hw-support
    steamdeck-hw-theme

    writeTextFile
    writeShellScript
    writeShellScriptBin
  ;

  # For optimal performance, Gamescope needs to Renice itself at
  # launch, it therefore needs the CAP_SYS_NICE capability. Bubblewrap
  # can't run a binary with such a capability without being Setuid
  # itself.
  steam =
  if pkgs ? "buildFHSEnv" then
    pkgs.steam.override {
      buildFHSEnv = pkgs.buildFHSEnv.override {
        bubblewrap = "${config.security.wrapperDir}/..";
      };
    }
  else
    pkgs.steam.override {
      buildFHSUserEnv = pkgs.buildFHSUserEnvBubblewrap.override {
        bubblewrap = "${config.security.wrapperDir}/..";
      };
    };

  cfg = config.jovian.steam;

  sessionPath = makeBinPath [
    mangohud
    systemd
    steam
    steam.run
  ];

  sessionEnvironment = builtins.concatStringsSep " " (mapAttrsToList (k: v: "${k}=${v}") config.jovian.steam.environment);

  # Shim that runs steam and associated services.
  steam-shim = writeShellScript "steam-shim" ''
    export PATH=${sessionPath}:$PATH

    export STEAM_USE_MANGOAPP=1
    export MANGOHUD_CONFIGFILE=$(mktemp $XDG_RUNTIME_DIR/mangohud.XXXXXXXX)

    powerbuttonPath="/dev/input/by-path/platform-i8042-serio-0-event-kbd"

    # Initially write no_display to our config file
    # so we don't get mangoapp showing up before Steam initializes
    # on OOBE and stuff.
    mkdir -p "$(dirname "$MANGOHUD_CONFIGFILE")"
    echo "no_display" > "$MANGOHUD_CONFIGFILE"

    # These additional services will be culled when the main service quits too.
    # This is done by re-using the same slice name.

    systemd-run --user \
      --collect \
      --slice="steam-session" \
      --unit=steam-session.mangoapp \
      --property=Restart=always \
      --setenv=DISPLAY \
      --setenv=MANGOHUD_CONFIGFILE \
      -- \
      mangoapp

    if test -r "$powerbuttonPath"; then
      systemd-run --user \
        --collect \
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

    if [[ -z "$XDG_SESSION_TYPE" ]]; then
      # See start-gamescope-session in the gamescope package for SteamOS
      echo ""
      echo "NOTE: Assuming this is running embedded (directly in a VT)"
      echo ""
      for var in DISPLAY XAUTHORITY; do
        unset "$var"
        export -n "$var"
        export XDG_SESSION_TYPE=x11
        export XDG_DESKTOP_PORTAL_DIR=""
      done
    else
      echo ""
      echo "NOTE: Assuming this is running nested (within a wayland or X11 session)"
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

    # Plop GAMESCOPE_MODE_SAVE_FILE into $XDG_CONFIG_HOME (defaults to ~/.config).
    export GAMESCOPE_MODE_SAVE_FILE="''${XDG_CONFIG_HOME:-$HOME/.config}/gamescope/modes.cfg"
    export GAMESCOPE_PATCHED_EDID_FILE="''${XDG_CONFIG_HOME:-$HOME/.config}/gamescope/edid.bin"

    exec ${config.security.wrapperDir}/gamescope "$@"
  '';

  # TODO: consume width/height script input params
  # TODO: consume script input param to disable fullscreening
  # TODO: pass down unhandled arguments
  # Script that launches the gamescope shim within a systemd scope.
  steam-session = writeShellScriptBin "steam-session" ''
    GAMESCOPE_WIDTH=''${GAMESCOPE_WIDTH:-1280}
    GAMESCOPE_HEIGHT=''${GAMESCOPE_HEIGHT:-800}

    SLICE="steam-session"

    runtime_dir="$XDG_RUNTIME_DIR/$SLICE.run"
    mkdir -p "$runtime_dir"
    export GAMESCOPE_STATS="$runtime_dir/stats.pipe"
    rm -f "$GAMESCOPE_STATS"
    mkfifo -- "$GAMESCOPE_STATS"

    # To play nice with the short term callback-based limiter for now
    #
    # This file is also read by the SteamOS version of Mesa/RADV to override
    # the swap interval.
    #
    # With pressure-vessel, only certain subpaths of $XDG_RUNTIME_DIR
    # are bind-mounted into the sandbox. As a result, we use --tmpdir here
    # instead of $runtime_dir.
    export GAMESCOPE_LIMITER_FILE=$(mktemp --tmpdir gamescope-limiter.XXXXXXXX)

    # Prepare our initial VRS config file for dynamic VRS in Mesa.
    #
    # Same as above.
    export RADV_FORCE_VRS_CONFIG_FILE=$(mktemp --tmpdir radv_vrs.XXXXXXXX)
    echo "1x1" > "$RADV_FORCE_VRS_CONFIG_FILE"

    # Prepare gamescope mode save file (3.1.44+)
    gamescope_config_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/gamescope"
    mkdir -p "$gamescope_config_dir"
    export GAMESCOPE_MODE_SAVE_FILE="$gamescope_config_dir/modes.cfg"
    touch "$GAMESCOPE_MODE_SAVE_FILE"

    gamescope_incantation=(
      "${gamescope-shim}"

      # Steam intrinsically knows it can use one of the layer for the
      # game, and the other for its overlay UI.
      # TODO[Jovian]: verify assertion
      --xwayland-count 2

      -w $GAMESCOPE_WIDTH -h $GAMESCOPE_HEIGHT

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

      systemd-run --user
        --collect
        --scope
        --slice="$SLICE"

      -- 

      "${steam-shim}" "$@"
    )

    at_exit() {
      systemctl --quiet --user stop "$SLICE.slice"
    }
    trap at_exit SIGINT SIGTERM EXIT

    PS4=" [steam-session] $ "
    set -x

    ${sessionEnvironment} "''${gamescope_incantation[@]}"
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
          description = lib.mdDoc ''
            Whether to enable the Steam Deck UI.

            When enabled, you can either launch the Steam Deck UI
            from your Display Manager or by running `steam-session`.
          '';
        };

        autoStart = mkOption {
          type = types.bool;
          default = false;
          description = lib.mdDoc ''
            Whether to automatically launch the Steam Deck UI on boot.

            Traditional Display Managers cannot be enabled in conjunction with this option.
          '';
        };

        user = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = lib.mdDoc ''
            The user to run Steam with.
          '';
        };

        desktopSession = mkOption {
          type = types.nullOr types.str;
          default = null;
          example = "plasma";
          description = lib.mdDoc ''
            The session to launch for Desktop Mode.

            By default, attempting to switch to the desktop will launch
            Gaming Mode again.
          '';
        };

        environment = mkOption {
          type = types.attrsOf types.str;
          default = {};
          description = lib.mdDoc ''
            Environment variables to set for Steam.
          '';
        };

        useStockEnvironment = mkOption {
          type = types.bool;
          default = true;
          description = lib.mdDoc ''
            Whether to use the stock environment variables from gamescope-session.
          '';
        };

        useStockSteamDeckEnvironment = mkOption {
          type = types.bool;
          default = config.jovian.devices.steamdeck.enable;
          defaultText = lib.literalExpression "config.jovian.devices.steamdeck.enable";
          description = lib.mdDoc ''
            Whether to use the Steam Deck-specific environment variables from stock gamescope-session.
          '';
        };
      };
    };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      security.wrappers.gamescope = {
        owner = "root";
        group = "root";
        source = "${gamescope}/bin/gamescope";
        capabilities = "cap_sys_nice+pie";
      };
    }
    {
      security.wrappers.bwrap = {
        owner = "root";
        group = "root";
        source = "${bubblewrap}/bin/bwrap";
        setuid = true;
      };
    }
    {
      warnings = []
        ++ lib.optional (!config.networking.networkmanager.enable)
          "The Steam Deck UI integrates with NetworkManager (networking.networkmanager.enable) which is not enabled. NetworkManager is required to complete the first-time setup process.";

      hardware.opengl.driSupport32Bit = true;
      hardware.pulseaudio.support32Bit = true;
      hardware.steam-hardware.enable = mkDefault true;

      environment.systemPackages = [ steam-session ];

      services.xserver.displayManager.sessionPackages = [ steam-session-desktop ];

      # Conflicts with power-button-handler
      services.logind.extraConfig = ''
        HandlePowerKey=ignore
      '';

      # This rule allows the user to configure Wi-Fi in Deck UI.
      #
      # Steam modifies the system network configs via
      # `org.freedesktop.NetworkManager.settings.modify.system`,
      # which normally requires being in the `networkmanager` group.
      security.polkit.extraConfig = ''
        // Jovian-NixOS/steam: Allow users to configure Wi-Fi in Deck UI
        polkit.addRule(function(action, subject) {
          if (
            action.id.indexOf("org.freedesktop.NetworkManager") == 0 &&
            subject.isInGroup("users") &&
            subject.local &&
            subject.active
          ) {
            return polkit.Result.YES;
          }
        });
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

        # Let steam know it can unmount drives without superuser privileges
        STEAM_ALLOW_DRIVE_UNMOUNT = "1";

        # Enable support for xwayland isolation per-game in Steam
        STEAM_MULTIPLE_XWAYLANDS = "1";

        # We have the Mesa integration for the fifo-based dynamic fps-limiter
        STEAM_GAMESCOPE_DYNAMIC_FPSLIMITER = "1";

        # We have gamma/degamma exponent support
        STEAM_GAMESCOPE_COLOR_TOYS = "1";

        # We have NIS support
        STEAM_GAMESCOPE_NIS_SUPPORTED = "1";

        # Support for gamescope tearing with GAMESCOPE_ALLOW_TEARING atom (3.11.44+)
        STEAM_GAMESCOPE_HAS_TEARING_SUPPORT = "1";

        # Enable tearing controls in steam
        STEAM_GAMESCOPE_TEARING_SUPPORTED = "1";

        # When set to 1, a toggle will show up in the steamui to control whether dynamic refresh rate is applied to the steamui
        STEAM_GAMESCOPE_DYNAMIC_REFRESH_IN_STEAM_SUPPORTED = "0";

        # Enable VRR controls in steam
        STEAM_GAMESCOPE_VRR_SUPPORTED = "1";

        # Scaling support
        STEAM_GAMESCOPE_FANCY_SCALING_SUPPORT = "1";

        # Color management support
        STEAM_GAMESCOPE_COLOR_MANAGED = "1";

        # Enable HDR support in steam
        STEAM_GAMESCOPE_HDR_SUPPORTED = "1";

        # Set refresh rate range and enable refresh rate switching
        STEAM_DISPLAY_REFRESH_LIMITS = "40,60";

        # We no longer need to set GAMESCOPE_EXTERNAL_OVERLAY from steam, mangoapp now does it itself
        STEAM_DISABLE_MANGOAPP_ATOM_WORKAROUND = "1";

        # Enable horizontal mangoapp bar
        STEAM_MANGOAPP_HORIZONTAL_SUPPORTED = "1";

        # Enable mangoapp overlay presets
        STEAM_MANGOAPP_PRESETS_SUPPORTED = "1";

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

        # Enabled fan control toggle in steam
        STEAM_ENABLE_FAN_CONTROL = "1";

        # Let's try this across the board to see if it breaks anything
        # Helps performance in HZD, Cyberpunk, at least
        # Expose 8 physical cores, instead of 4c/8t
        WINE_CPU_TOPOLOGY = "8:0,1,2,3,4,5,6,7";
      };
    })
    (mkIf cfg.autoStart {
      assertions = [
        {
          assertion = !config.systemd.services.display-manager.enable;
          message = ''
            Traditional Display Managers cannot be enabled when jovian.steam.autoStart is used

            Hint: check `services.xserver.displaymanager.*.enable` options in your configuration.
          '';
        }
      ];

      warnings = lib.optional (cfg.desktopSession == null) ''
        jovian.steam.desktopSession is unset.

        This means that using the Switch to Desktop function in Gaming Mode will
        relaunch Gaming Mode.

        Set jovian.steam.desktopSession to the name of a desktop session, or "steam-wayland"
        to keep this behavior.
      '';

      services.xserver = {
        enable = true;
        displayManager.lightdm.enable = false;
        displayManager.startx.enable = true;
      };

      jovian.steam.environment = {
        JOVIAN_DESKTOP_SESSION = if cfg.desktopSession != null then cfg.desktopSession else "steam-wayland";
      };

      services.greetd = {
        enable = true;
        settings = {
          default_session = let
          in {
            user = "jovian-greeter";
            command = "${pkgs.jovian-greeter}/bin/jovian-greeter ${cfg.user}";
          };
        };
      };

      users.users.jovian-greeter = {
        isSystemUser = true;
        group = "jovian-greeter";
      };
      users.groups.jovian-greeter = {};

      security.pam.services = {
        greetd.text = ''
          auth      requisite     pam_nologin.so
          auth      sufficient    pam_succeed_if.so user = ${cfg.user} quiet_success
          auth      required      pam_unix.so

          account   sufficient    pam_unix.so

          password  required      pam_deny.so

          session   optional      pam_keyinit.so revoke
          session   include       login
        '';
      };

      environment = {
        systemPackages = [ pkgs.jovian-greeter.helper ];
        pathsToLink = [ "lib/jovian-greeter" ];
      };
      security.polkit.extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (
            action.id == "org.freedesktop.policykit.exec" &&
            action.lookup("program") == "/run/current-system/sw/lib/jovian-greeter/consume-session" &&
            subject.user == "jovian-greeter"
          ) {
            return polkit.Result.YES;
          }
        });
      '';
    })
  ]);
}
