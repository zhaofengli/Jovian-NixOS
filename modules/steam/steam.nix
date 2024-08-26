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

      security.wrappers.galileo-mura-extractor = {
        owner = "root";
        group = "root";
        source = "${pkgs.galileo-mura}/bin/galileo-mura-extractor";
        setuid = true;
      };
    }
    {
      # Enable the usual desktop Steam stuff
      programs.steam.enable = mkDefault true;

      # Enable MTU probing, as vendor does
      # See: https://github.com/ValveSoftware/SteamOS/issues/1006
      # See also: https://www.reddit.com/r/SteamDeck/comments/ymqvbz/ubisoft_connect_connection_lost_stuck/j36kk4w/?context=3
      boot.kernel.sysctl."net.ipv4.tcp_mtu_probing" = true;

      hardware.graphics = {
        enable32Bit = true;
        extraPackages = [ pkgs.gamescope-wsi ];
        extraPackages32 = [ pkgs.pkgsi686Linux.gamescope-wsi ];
      };

      hardware.pulseaudio.support32Bit = true;
      hardware.steam-hardware.enable = mkDefault true;

      environment.systemPackages = [ pkgs.gamescope-session pkgs.steamos-polkit-helpers pkgs.steamos-manager ];

      systemd.packages = [ pkgs.gamescope-session pkgs.steamos-manager ];

      # Vendor patch: https://raw.githubusercontent.com/Jovian-Experiments/PKGBUILDs-mirror/cdaeca26642d59fc9109e98ac9ce2efe5261df1b/0001-Add-systemd-service.patch
      systemd.user.services.wakehook = {
        wantedBy = ["gamescope-session.service"];
        after = ["gamescope-session.service"];
        serviceConfig = {
          ExecStart = lib.getExe pkgs.wakehook;
          Restart = "always";
        };
      };

      systemd.user.services.steamos-manager = {
        overrideStrategy = "asDropin";
        wantedBy = [ "gamescope-session.service" ];
      };

      services.dbus.packages = [ pkgs.steamos-manager ];

      services.displayManager.sessionPackages = [ pkgs.gamescope-session ];

      # Conflicts with powerbuttond
      services.logind.extraConfig = ''
        HandlePowerKey=ignore
      '';

      services.udev.packages = [
        pkgs.powerbuttond
      ];

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

      jovian.steam.environment = {
        # We don't support adopting a drive, yet.
        STEAM_ALLOW_DRIVE_ADOPT = mkDefault "0";
        # Ejecting doesn't work, either.
        STEAM_ALLOW_DRIVE_UNMOUNT = mkDefault "0";
      };
    }
  ]);
}
