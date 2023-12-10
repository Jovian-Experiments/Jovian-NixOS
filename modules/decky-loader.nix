{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkDefault
    mkIf
    mkMerge
    mkOption
    types
  ;
  cfg = config.jovian.decky-loader;
in
{
  options = {
    jovian = {
      decky-loader = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = lib.mdDoc ''
            Whether to enable the Steam Deck Plugin Loader.
          '';
        };

        enableFHSEnvironment = mkOption {
          type = types.bool;
          default = false;
          description = lib.mdDoc ''
            Allows plugins shipping with prebuilt binaries to function (e.g. PowerTools).
          '';
        };

        package = mkOption {
          type = types.package;
          default = pkgs.decky-loader;
          defaultText = lib.literalExpression "pkgs.decky-loader";
          description = lib.mdDoc ''
            The loader package to use.
          '';
        };

        extraPackages = mkOption {
          type = types.listOf types.package;
          example = lib.literalExpression "[ pkgs.curl pkgs.unzip ]";
          default = [];
          description = lib.mdDoc ''
            Extra packages to add to the service PATH.
          '';
        };

        extraPythonPackages = mkOption {
          type = types.functionTo (types.listOf types.package);
          example = lib.literalExpression "pythonPackages: with pythonPackages; [ hid ]";
          default = pythonPackages: with pythonPackages; [];
          defaultText = lib.literalExpression "pythonPackages: with pythonPackages; []";
          description = lib.mdDoc ''
            Extra Python packages to add to the PYTHONPATH of the loader.
          '';
        };

        stateDir = mkOption {
          type = types.path;
          default = "/var/lib/decky-loader";
          description = lib.mdDoc ''
            Directory to store plugins and data.
          '';
        };

        user = mkOption {
          type = types.str;
          default = "decky";
          description = lib.mdDoc ''
            The user Decky Loader should run plugins as.
          '';
        };
      };
    };
  };

  config = mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf (cfg.user == "decky") {
      users.users.decky = {
        group = "decky";
        home = cfg.stateDir;
        isSystemUser = true;
      };
      users.groups.decky = {};
    })
    {
      # As of 2023/07/16, the Decky Loader needs to run as root, even if you never
      # use plugins that require it. It setuid's to the unprivileged user to
      # run plugins. Running as non-root is unsupported and currently breaks:
      #
      # <https://github.com/SteamDeckHomebrew/decky-loader/issues/446#issuecomment-1637177368>
      systemd.services.decky-loader = {
        description = "Steam Deck Plugin Loader";

        wantedBy = [ "multi-user.target" ];

        environment = let
          inherit (cfg.package.passthru) python;
        in {
          UNPRIVILEGED_USER = cfg.user;
          UNPRIVILEGED_PATH = cfg.stateDir;
          PLUGIN_PATH = "${cfg.stateDir}/plugins";
          PYTHONPATH = "${python.withPackages cfg.extraPythonPackages}/${python.sitePackages}";
        };

        path = with pkgs; [ coreutils gawk ] ++ cfg.extraPackages;

        preStart = ''
          mkdir -p "${cfg.stateDir}"
          chown -R "${cfg.user}:" "${cfg.stateDir}"
        '';

        serviceConfig = let
          decky-loader = if !cfg.enableFHSEnvironment then
            "${cfg.package}"
          else
            pkgs.buildFHSEnv {
              name = "decky-loader";
              runScript = "${cfg.package}/bin/decky-loader";
            };
        in {
          ExecStart = "${decky-loader}/bin/decky-loader";
          KillSignal = "SIGINT";
        };
      };
    }
  ]);
}
