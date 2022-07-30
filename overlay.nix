final: super:

let
  inherit (final)
    kernelPatches
    linuxPackagesFor
  ;
in
{
  acp5x-ucm = final.callPackage ./pkgs/acp5x-ucm { };
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
  gamescope = super.callPackage ./pkgs/gamescope {
    udev = final.systemdMinimal;
  };
  gamescope-session = super.callPackage ./pkgs/gamescope-session { };

  jupiter-fan-control = final.callPackage ./pkgs/jupiter-fan-control { };

  jupiter-hw-support = final.callPackage ./pkgs/jupiter-hw-support { };
  steamdeck-hw-theme = final.callPackage ./pkgs/jupiter-hw-support/theme.nix { };
  steamdeck-firmware = final.callPackage ./pkgs/jupiter-hw-support/firmware.nix { };

  steamdeck-theme = final.callPackage ./pkgs/steamdeck-theme { };
}
