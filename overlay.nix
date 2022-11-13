final: super:

let
  inherit (final)
    kernelPatches
    linuxPackagesFor
  ;
in
{
  linux-firmware = final.callPackage ./pkgs/linux-firmware {
    linux-firmware = super.linux-firmware;
  };
  linuxPackages_jovian = linuxPackagesFor final.linux_jovian;
  linux_jovian = super.callPackage ./pkgs/linux-jovian {
    kernelPatches = [
      kernelPatches.bridge_stp_helper
      kernelPatches.request_key_helper
      kernelPatches.export-rt-sched-migrate
    ];
  };
  linuxPackages_jovian_guest = linuxPackagesFor final.linux_jovian_guest;
  linux_jovian_guest = final.linux_jovian.override {
    guestSupport = true;
  };

  linuxPackages_jovian_6_0 = linuxPackagesFor final.linux_jovian_6_0;
  linux_jovian_6_0 = super.callPackage ./pkgs/linux-jovian/6_0.nix {
    kernelPatches = [
      kernelPatches.bridge_stp_helper
      kernelPatches.request_key_helper
      kernelPatches.export-rt-sched-migrate
    ];
  };

  mangohud = final.callPackage ./pkgs/mangohud {
    inherit (super) mangohud;
  };

  mesa-radv-jupiter = final.callPackage ./pkgs/mesa-radv-jupiter { };

  xwayland-jupiter = final.callPackage ./pkgs/xwayland-jupiter { };
  gamescope = super.gamescope.override {
    wlroots = final.wlroots.override {
      xwayland = final.xwayland-jupiter;
    };
    xwayland = final.xwayland-jupiter;
  };

  jupiter-fan-control = final.callPackage ./pkgs/jupiter-fan-control { };

  jupiter-hw-support = final.callPackage ./pkgs/jupiter-hw-support { };
  steamdeck-hw-theme = final.callPackage ./pkgs/jupiter-hw-support/theme.nix { };
  steamdeck-firmware = final.callPackage ./pkgs/jupiter-hw-support/firmware.nix { };
  steamdeck-bios-fwupd = final.callPackage ./pkgs/jupiter-hw-support/bios-fwupd.nix { };

  jupiter-dock-updater-bin = final.callPackage ./pkgs/jupiter-dock-updater-bin { };

  steamdeck-theme = final.callPackage ./pkgs/steamdeck-theme { };

  sdgyrodsu = final.callPackage ./pkgs/sdgyrodsu { };

  decky-loader = final.callPackage ./pkgs/decky-loader { };

  opensd = super.callPackage ./pkgs/opensd { };

  steamPackages = super.steamPackages.overrideScope (scopeFinal: scopeSuper: {
    steam = final.callPackage ./pkgs/steam-jupiter/unwrapped.nix {
      steam-original = scopeSuper.steam;
    };
    steam-fhsenv = final.callPackage ./pkgs/steam-jupiter/fhsenv.nix {
      steam-fhsenv = scopeSuper.steam-fhsenv;
    };
  });
}
