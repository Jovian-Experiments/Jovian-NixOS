{lib, config, pkgs, ...}: let
  inherit (lib) mkOption literalExpression types mdDoc mkIf;
  cfg = config.jovian.steam;
in {
  options.jovian.steam.network = {
    enable = mkOption {
      description = mdDoc "Open required ports for Local Transfers";
      type = types.bool;
      default = cfg.enable;
      defaultText = literalExpression "config.jovian.steam.enable";
    };
  };
  config = mkIf cfg.network.enable {
    networking.firewall = {
      allowedTCPPorts = [
        24070 # Local Transfers
        27036 # Remote Play without this Local Transfers do not work but remote play works fine
      ];
    };
  };
}
