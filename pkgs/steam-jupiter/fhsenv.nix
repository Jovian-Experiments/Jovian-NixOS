# A wrapped version of Steam with shims to satisfy the SteamOS-only
# dependencies of the Steam Deck UI

{ writeShellScriptBin
, dmidecode
, jovian-stubs
, steam

# We need to add this flag when Steam is started directly (e.g., desktop mode)
# so we have the correct client version. This is important even for desktop
# use because only the Steam Deck branch of the client has the new on-screen
# keyboard that's summoned with STEAM + X.
, platformArgs ? "-steamdeck"
, ...
} @ args:

let
  extraArgs = builtins.removeAttrs args [
    "lib"
    "runCommand"
    "writeShellScriptBin"
    "dmidecode"
    "jovian-stubs"
    "platformArgs"
    "steam"
  ];

  wrappedSteam = steam.override (extraArgs // {
    extraPkgs = pkgs: (if args ? extraPkgs then args.extraPkgs pkgs else [ ]) ++ [
      dmidecode
      jovian-stubs
    ];
    extraProfile = (args.extraProfile or "") + ''
      export PATH=${jovian-stubs}/bin:$PATH
    '';

    # Force using host /tmp so gamescope-session can find the magic files
    extraBwrapArgs = (args.extraBwrapArgs or [ ]) ++ [
      "--bind /tmp /tmp"
    ];

    extraArgs = (args.extraArgs or "") + " " + platformArgs;
  });
in
wrappedSteam
