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
          description = ''
            Whether to enable the Steam Deck Plugin Loader.

            Currently this is very YMMV. Some of the plugins make
            unsound assumption on the system (e.g., HOME being
            /home/deck), and the loader itself requires root.
          '';
        };

        pluginPath = mkOption {
          type = types.path;
          example = "/home/deck/homebrew/plugins";
          description = ''
            The directory to store the plugins under.
          '';
        };

        extraPackages = mkOption {
          type = types.listOf types.package;
          example = lib.literalExpression "[ pkgs.curl pkgs.unzip ] # CSS Loader";
          default = [];
          description = ''
            Extra packages to add to the service PATH.
          '';
        };
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.decky-loader = {
      description = "Steam Deck Plugin Loader";

      wantedBy = [ "multi-user.target" ];

      environment = {
        PLUGIN_PATH = cfg.pluginPath;
      };

      path = with pkgs; [ coreutils gawk ] ++ cfg.extraPackages;

      preStart = ''
        mkdir -p $PLUGIN_PATH
      '';

      serviceConfig = {
        ExecStart = "${pkgs.decky-loader}/bin/decky-loader";
        KillSignal = "SIGINT"; # smh
      };
    };
  };
}
