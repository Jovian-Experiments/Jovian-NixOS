# A wrapped version of Steam with shims to satisfy the SteamOS-only
# dependencies of the Steam Deck UI

{ lib
, runCommand
, writeShellScriptBin
, steam-fhsenv
, ...
} @ args:

let
  extraArgs = builtins.removeAttrs args [ "lib" "runCommand" "writeShellScriptBin" "steam-fhsenv" ];

  # The sudo wrapper doesn't work in FHS environments. For our purposes
  # we add a passthrough sudo command that does not actually escalate
  # privileges.
  #
  # <https://github.com/NixOS/nixpkgs/issues/42117>
  passthroughSudo = writeShellScriptBin "sudo" ''
    declare -a final

    positional=""
    for value in "$@"; do
      if [[ -n "$positional" ]]; then
        final+=("$value")
      elif [[ "$value" == "-n" ]]; then
        :
      else
        positional="y"
        final+=("$value")
      fi
    done

    exec "''${final[@]}"
  '';

  # Null SteamOS updater that does nothing
  #
  # This gets us past the OS update step in the OOBE wizard.
  nullOsUpdater = writeShellScriptBin "steamos-update" ''
    >&2 echo "steamos-update: Not supported on NixOS - Doing nothing"
    exit 7;
  '';

  # Null Steam Deck BIOS updater that does nothing
  nullBiosUpdater = writeShellScriptBin "jupiter-biosupdate" ''
    >&2 echo "jupiter-biosupdate: Doing nothing"
  '';

  # A very simplistic "session switcher." All it does is kill gamescope.
  sessionSwitcher = writeShellScriptBin "steamos-session-select" ''
    session="''${1:-gamescope}"

    >>~/gamescope.log echo "steamos-session-select: switching to $session"

    if [[ "$session" != "plasma" ]]; then
      >&2 echo "!! Unsupported session '$session'"
      >&2 echo "Currently this can only be called by Steam to switch to Desktop Mode"
      exit 1
    fi

    if [[ -n "$JOVIAN_DESKTOP_SESSION" ]]; then
      session="$JOVIAN_DESKTOP_SESSION"
      >&2 echo "Using preferred session '$session'"
    fi

    mkdir -p ~/.local/state
    >~/.local/state/steamos-session-select echo "$session"

    if [[ -n "$gamescope_pid" ]]; then
      kill "$gamescope_pid"
    else
      >&2 echo "!! Don't know how to kill gamescope"
      exit 1
    fi
  '';

  wrappedSteam = steam-fhsenv.override (extraArgs // {
    extraPkgs = pkgs: (if args ? extraPkgs then args.extraPkgs pkgs else []) ++ [
      nullOsUpdater nullBiosUpdater
      sessionSwitcher
    ];
    extraProfile = (args.extraProfile or "") + ''
      export PATH=${passthroughSudo}/bin:$PATH
    '';

    # We need to add this flag when Steam is started directly (e.g., desktop mode)
    # so we have the correct client version. This is important even for desktop
    # use because only the Steam Deck branch of the client has the new on-screen
    # keyboard that's summoned with STEAM + X.
    extraArgs = "-steamdeck";
  });
in wrappedSteam
