{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkDefault
    mkIf
    mkMerge
    mkOption
    types
  ;

  cfg = config.jovian.steam;

  gamescope-session = if cfg.useAlternativePowerButtonHandler then pkgs.gamescope-session.override {
    powerbuttond = pkgs.writeShellScriptBin "powerbuttond" ''
      exec ${pkgs.steamPackages.steam-fhsenv.run}/bin/steam-run ${pkgs.jovian-power-button-handler}/bin/power-button-handler \
        --device "${cfg.powerButtonDevice}"
    '';
  } else pkgs.gamescope-session;
in
{
  options = {
    jovian.steam = {
      useAlternativePowerButtonHandler = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to use an alternative implementation of the power button handler.

          This is required to use alternative power button devices.
        '';
      };
      powerButtonDevice = mkOption {
        type = types.nullOr types.str;
        default = "isa0060/serio0/input0";
        description = ''
          The PHYS attribute of the power button device.

          This is only used when `useAlternativePowerButtonHandler` is true.
        '';
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      warnings = []
        ++ lib.optional (!config.networking.networkmanager.enable)
          "The Steam Deck UI integrates with NetworkManager (networking.networkmanager.enable) which is not enabled. NetworkManager is required to complete the first-time setup process.";
    }
    {
      security.wrappers.gamescope = {
        owner = "root";
        group = "root";
        source = "${pkgs.gamescope}/bin/gamescope";
        capabilities = "cap_sys_nice+pie";
      };
    }
    {
      hardware.opengl.driSupport32Bit = true;
      hardware.pulseaudio.support32Bit = true;
      hardware.steam-hardware.enable = mkDefault true;

      environment.systemPackages = [ gamescope-session pkgs.steamos-polkit-helpers ];

      systemd.packages = [ gamescope-session ];

      services.xserver.displayManager.sessionPackages = [ gamescope-session ];

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
  ]);
}
