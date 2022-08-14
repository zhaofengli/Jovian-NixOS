{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkIf
    mkOption
    types
  ;
  cfg = config.jovian.devices.steamdeck;
in
{
  options = {
    jovian.devices.steamdeck = {
      enableGyroDsuService = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable the Cemuhook DSU service for the gyroscope.

          If enabled, motion data from the gyroscope can be used in Cemu
          with Cemuhook.
        '';
      };
    };
  };
  config = mkIf cfg.enableGyroDsuService {
    assertions = [
      {
        assertion = cfg.enableGyroDsuService -> cfg.enableControllerUdevRules;
        message = "jovian.devices.steamdeck.enableControllerUdevRules must be enabled for enableGyroDsuService";
      }
    ];

    systemd.services.sdgyrodsu = {
      description = "Cemuhook DSU server for the Steam Deck Gyroscope";
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.usbutils ];
      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${pkgs.sdgyrodsu}/bin/sdgyrodsu";
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
      };
    };
  };
}
