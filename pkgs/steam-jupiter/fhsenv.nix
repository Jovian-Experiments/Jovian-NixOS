# A wrapped version of Steam with shims to satisfy the SteamOS-only
# dependencies of the Steam Deck UI

{ lib
, runCommand
, writeShellScriptBin
, dmidecode
, jovian-stubs
, steam-fhsenv
, steamos-polkit-helpers
, ...
} @ args:

let
  extraArgs = builtins.removeAttrs args [
    "lib"
    "runCommand"
    "writeShellScriptBin"
    "dmidecode"
    "jovian-stubs"
    "steam-fhsenv"
    "steamos-polkit-helpers"
  ];

  # A very simplistic "session switcher." All it does is kill gamescope.
  sessionSwitcher = writeShellScriptBin "steamos-session-select" ''
    session="''${1:-gamescope}"

    echo "steamos-session-select: switching to $session"

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

    systemctl stop --user gamescope-session
  '';

  wrappedSteam = steam-fhsenv.override (extraArgs // {
    extraPkgs = pkgs: (if args ? extraPkgs then args.extraPkgs pkgs else []) ++ [
      dmidecode
      jovian-stubs
      sessionSwitcher
      steamos-polkit-helpers
    ];
    extraProfile = (args.extraProfile or "") + ''
      export PATH=${jovian-stubs}/bin:$PATH
    '';

    # We need to add this flag when Steam is started directly (e.g., desktop mode)
    # so we have the correct client version. This is important even for desktop
    # use because only the Steam Deck branch of the client has the new on-screen
    # keyboard that's summoned with STEAM + X.
    extraArgs = "-steamdeck";
  });
in wrappedSteam
