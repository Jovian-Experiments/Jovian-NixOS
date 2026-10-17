{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkIf
    mkOption
    types
  ;
  cfg = config.jovian.decky-loader;

  package = cfg.package.overridePythonAttrs(old: {
    dependencies = old.dependencies ++ (cfg.extraPythonPackages old.passthru.python.pkgs);
  });
in
{
  options = {
    jovian = {
      decky-loader = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Whether to enable the Steam Deck Plugin Loader.
          '';
        };

        package = mkOption {
          type = types.package;
          default = pkgs.decky-loader;
          defaultText = lib.literalExpression "pkgs.decky-loader";
          description = ''
            The loader package to use.
          '';
        };

        extraPackages = mkOption {
          type = types.listOf types.package;
          example = lib.literalExpression "[ pkgs.curl pkgs.unzip ]";
          default = [];
          description = ''
            Extra packages to add to the service PATH.
          '';
        };

        extraPythonPackages = mkOption {
          type = types.functionTo (types.listOf types.package);
          example = lib.literalExpression "pythonPackages: with pythonPackages; [ hid ]";
          default = _: [];
          defaultText = lib.literalExpression "pythonPackages: []";
          description = ''
            Extra Python packages to add to the PYTHONPATH of the loader.
          '';
        };

        stateDir = mkOption {
          type = types.path;
          default = "/var/lib/decky-loader";
          description = ''
            Directory to store plugins and data.
          '';
        };

        user = mkOption {
          type = types.str;
          default = "decky";
          description = ''
            The user Decky Loader should run plugins as.
          '';
        };

        plugins = mkOption {
          type = types.listOf types.package;
          default = [ ];
          description = ''
            Plugins to install
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

    (lib.mkIf (cfg.plugins != []) {
      systemd.tmpfiles.settings =  let
        pluginsDir = pkgs.symlinkJoin {
          name = "decky-plugins-folder";
          paths = cfg.plugins;
        };
      in
        {
          "10-decky-plugins" = {
            "${cfg.stateDir}/plugins" = {
              "L+" = {
                group = "${config.users.users.${cfg.user}.group}";
                mode = "0755";
                user = "${cfg.user}";
                argument = "${pluginsDir}/plugins";
              };
            };
          };
        };
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
        after = [ "network.target" ];

        environment = {
          UNPRIVILEGED_USER = cfg.user;
          UNPRIVILEGED_PATH = cfg.stateDir;
          PLUGIN_PATH = "${cfg.stateDir}/plugins";
        };

        path = cfg.extraPackages;

        preStart = ''
          mkdir -p "${cfg.stateDir}"
          chown -R "${cfg.user}:" "${cfg.stateDir}"
        '';

        serviceConfig = {
          ExecStart = "${package}/bin/decky-loader";
          KillMode = "process";
          TimeoutStopSec = 45;
        };
      };
    }
  ]);
}
