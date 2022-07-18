{ lib, stdenv, python3, fetchurl, git, xorg }:

stdenv.mkDerivation rec {
  pname = "jupiter-hw-support";
  version = "20220708.1-2";

  src = fetchurl {
    url = "https://steamdeck-packages.steamos.cloud/archlinux-mirror/sources/jupiter-main/jupiter-hw-support-${version}.src.tar.gz";
    sha256 = "sha256-e+PGN3phiGe8JX56/DUL9g9B7AEvdNSZLprwzS4MhpI=";
  };

  nativeBuildInputs = [
    git
    xorg.xcursorgen
  ];

  buildInputs = [
    (python3.withPackages (py: with py; [
      evdev
      crcmod
      click
      progressbar
      hid
    ]))
  ];

  unpackPhase = ''
    tar xpf $src jupiter-hw-support/jupiter-hw-support --strip-components=1
    mv jupiter-hw-support{,.git}

    git clone jupiter-hw-support.git jupiter-hw-support
  '';

  sourceRoot = "jupiter-hw-support";

  installPhase = ''
    mkdir -p $out/lib
    cp -r usr/lib/hwsupport $out/lib

    mkdir -p $out/share
    cp -r usr/share/icons $out/share
    cp -r usr/share/steamos $out/share
    cp -r usr/share/plymouth $out/share
    cp -r usr/share/jupiter_bios $out/share
    cp -r usr/share/jupiter_bios_updater $out/share
    cp -r usr/share/jupiter_controller_fw_updater $out/share

    pushd $out/share/steamos
    xcursorgen steamos-cursor-config $out/share/icons/steam/cursors/default
    popd

    pushd $out/share/jupiter_bios_updater
    # Upstream comment:
    # > Remove gtk2 binary and respective build/start script - unused
    # > Attempts to use gtk2 libraries which are not on the device.
    rm h2offt-g H2OFFTx64-G.sh
    popd
  '';

  meta = with lib; {
    description = "Steam Deck (Jupiter) hardware support package";
    # Said to be MIT in PKGBUILD, but should actually be unfree given
    # the contents.
    license = licenses.unfree;
  };
}
