{ lib
, runCommand
, steam
, gamescope
, mangohud
, jupiter-hw-support
, steamdeck-hw-theme
, writeShellScriptBin
}:

# TODO: Integrate this into modules/steam.nix. steam-session can be run on an
# existing desktop, in which case gamescope will be started in nested mode.

let
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

    mkdir -p ~/.local/state
    >~/.local/state/steamos-session-select echo "$session"

    if [[ -n "$gamescope_pid" ]]; then
      kill "$gamescope_pid"
    else
      >&2 echo "!! Don't know how to kill gamescope"
      exit 1
    fi
  '';

  wrappedSteam = steam.override {
    extraPkgs = pkgs: [
      nullOsUpdater nullBiosUpdater
      sessionSwitcher
    ];
    extraProfile = ''
      export PATH=${passthroughSudo}/bin:$PATH
    '';
  };

  binPath = lib.makeBinPath [ wrappedSteam wrappedSteam.run gamescope mangohud ];
in runCommand "steam-session" {
  passthru.steam = wrappedSteam;
  passthru.providedSessions = [ "steam-wayland" ];
} ''
  mkdir -p $out/bin
  path=${binPath} hwsupport=${jupiter-hw-support} theme=${steamdeck-hw-theme}\
    substituteAll ${./steam-session} $out/bin/steam-session
  chmod +x $out/bin/steam-session

  mkdir -p $out/share/wayland-sessions
  substituteAll ${./steam-wayland.desktop.in} $out/share/wayland-sessions/steam-wayland.desktop
''
