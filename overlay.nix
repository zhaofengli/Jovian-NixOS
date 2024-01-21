final: super:

let
  inherit (final)
    kernelPatches
    linuxPackagesFor
  ;
  linuxModulesOverlay = final: super: {
    ayn-platform = final.callPackage ./pkgs/ayn-platform { };
    ryzen_smu = final.callPackage ./pkgs/ryzen_smu { };
  };
in
rec {
  linuxKernel = super.linuxKernel // {
    packagesFor = kernel: (super.linuxKernel.packagesFor kernel).extend linuxModulesOverlay;
  };

  linux-firmware-jupiter = final.callPackage ./pkgs/linux-firmware {
    linux-firmware = super.linux-firmware;
  };
  linuxPackages_jovian = linuxPackagesFor final.linux_jovian;
  linux_jovian = final.callPackage ./pkgs/linux-jovian {
    kernelPatches = [
      kernelPatches.bridge_stp_helper
      kernelPatches.request_key_helper
      kernelPatches.export-rt-sched-migrate
    ];
  };

  galileo-mura = final.callPackage ./pkgs/galileo-mura { };

  gamescope = import ./pkgs/gamescope {
    gamescope' = super.gamescope;
    fetchFromGitHub = super.fetchFromGitHub;
  };
  gamescope-wsi = gamescope.override {
    enableExecutable = false;
    enableWsi = true;
  };
  gamescope-session = final.callPackage ./pkgs/gamescope-session { };

  mangohud = final.callPackage ./pkgs/mangohud {
    libXNVCtrl = linuxPackages_jovian.nvidia_x11.settings.libXNVCtrl;
    mangohud32 = final.pkgsi686Linux.mangohud;
    inherit (final.python3Packages) mako;
  };

  mesa-radv-jupiter = final.callPackage ./pkgs/mesa-radv-jupiter {
    # Compat with the inputs from Nixpkgs; those are for Darwin.
    OpenGL = null;
    Xplugin = null;
  };

  jupiter-fan-control = final.callPackage ./pkgs/jupiter-fan-control { };
  powerbuttond = final.callPackage ./pkgs/powerbuttond { };
  steam_notif_daemon = final.callPackage ./pkgs/steam_notif_daemon { };

  jupiter-hw-support = final.callPackage ./pkgs/jupiter-hw-support { };
  steamdeck-hw-theme = final.callPackage ./pkgs/jupiter-hw-support/theme.nix { };
  steamdeck-firmware = final.callPackage ./pkgs/jupiter-hw-support/firmware.nix { };
  steamdeck-bios-fwupd = final.callPackage ./pkgs/jupiter-hw-support/bios-fwupd.nix { };

  jupiter-dock-updater-bin = final.callPackage ./pkgs/jupiter-dock-updater-bin { };
  steamos-polkit-helpers = final.callPackage ./pkgs/jupiter-hw-support/polkit-helpers.nix { };
  steamdeck-dsp = final.callPackage ./pkgs/steamdeck-dsp { };

  steamdeck-theme = final.callPackage ./pkgs/steamdeck-theme { };

  opensd = final.callPackage ./pkgs/opensd { };

  jovian-stubs = final.callPackage ./pkgs/jovian-stubs { };
  jovian-greeter = final.callPackage ./pkgs/jovian-greeter { };
  jovian-steam-protocol-handler = final.callPackage ./pkgs/jovian-steam-protocol-handler { };

  jovian-documentation = final.callPackage ./support/docs {
    pagefind = final.callPackage ./pkgs/pagefind { };
    documentationPath = final.callPackage (
      { runCommand
      }:
      runCommand "jovian-documentation-source" {
        src = ./docs;
      } ''
        (PS4=" $ "; set -x
        cp --no-preserve=mode -r $src src
        chmod -R +w src
        rm -vf src/README.md
        cp -v ${./CONTRIBUTING.md} src/contributing.md
        printf '# Home\n\n' | cat - ${./README.md} > src/index.md
        cp -v ${./support/docs/search.md} src/search.md
        mv src $out
        )
      ''
    ) { };
  };

  jovian-power-button-handler = super.callPackage ./pkgs/jovian-power-button-handler { };

  jovian-hardware-survey = final.callPackage ./pkgs/jovian-hardware-survey { };

  steamPackages = super.steamPackages.overrideScope (scopeFinal: scopeSuper: {
    steam = final.callPackage ./pkgs/steam-jupiter/unwrapped.nix {
      steam-original = scopeSuper.steam;
    };
    steam-fhsenv = final.callPackage ./pkgs/steam-jupiter/fhsenv.nix {
      steam-fhsenv = scopeSuper.steam-fhsenv;
    };
    steam-fhsenv-small = final.callPackage ./pkgs/steam-jupiter/fhsenv.nix {
      steam-fhsenv = scopeSuper.steam-fhsenv-small;
    };
  });

  wireplumber-jovian = final.callPackage ./pkgs/wireplumber { 
    wireplumber' = super.wireplumber;
  };

  sdgyrodsu = final.callPackage ./pkgs/sdgyrodsu { };

  decky-loader = final.callPackage ./pkgs/decky-loader { };
}
