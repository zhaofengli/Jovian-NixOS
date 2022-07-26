{ lib
, stdenv
, fetchFromGitHub
, autoPatchelfHook
, makeWrapper
, python3
, xorg

# jupiter-biosupdate
, libkrb5
, zlib
, jq
, dmidecode
}:

let
  pythonEnv = python3.withPackages (py: with py; [
    evdev
    crcmod
    click
    progressbar
    hid
  ]);
in
stdenv.mkDerivation rec {
  pname = "jupiter-hw-support";
  version = "20220721.3";

  outputs = [ "out" "theme" "firmware" ];

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "jupiter-hw-support";
    rev = "jupiter-${version}";
    sha256 = "sha256-uJZMFxiDcmzkLOp6NXHfRL4FBZbCkau5A/snW4j2Zrg=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    xorg.xcursorgen
  ];

  buildInputs = [
    # auto patchelf
    libkrb5
    zlib
    stdenv.cc.cc # libstdc++.so.6

    pythonEnv
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # Themes

    mkdir -p $theme/share
    cp -r usr/share/icons $theme/share
    cp -r usr/share/plymouth $theme/share
    cp -r usr/share/steamos $theme/share

    sed -i "s|/usr/|$out/|g" $theme/share/plymouth/themes/steamos/steamos.plymouth

    pushd $theme/share/steamos
    xcursorgen steamos-cursor-config $theme/share/icons/steam/cursors/default
    popd

    # Firmware

    mkdir -p $firmware/{bin,share}
    cp -r usr/share/jupiter_bios $firmware/share
    cp -r usr/share/jupiter_bios_updater $firmware/share
    cp -r usr/share/jupiter_controller_fw_updater $firmware/share

    cp usr/bin/jupiter-biosupdate $firmware/bin
    sed -i "s|/usr/|$firmware/|g" $firmware/bin/jupiter-biosupdate
    wrapProgram $firmware/bin/jupiter-biosupdate \
      --prefix PATH : ${lib.makeBinPath [ jq dmidecode ]}

    cp usr/bin/jupiter-controller-update $firmware/bin
    sed -i "s|/usr/|$firmware/|g" $firmware/bin/jupiter-controller-update
    wrapProgram $firmware/bin/jupiter-controller-update \
      --prefix PATH : ${lib.makeBinPath [ jq pythonEnv ]}

    pushd $firmware/share/jupiter_bios_updater
    # Upstream comment:
    # > Remove gtk2 binary and respective build/start script - unused
    # > Attempts to use gtk2 libraries which are not on the device.
    rm h2offt-g H2OFFTx64-G.sh
    popd

    # Others

    mkdir -p $out/lib
    cp -r usr/lib/hwsupport $out/lib

    mkdir -p $out/share
    cp -r usr/share/alsa $out/share

    runHook postInstall
  '';

  meta = with lib; {
    description = "Steam Deck (Jupiter) hardware support package";
    # Said to be MIT in PKGBUILD, but should actually be unfree given
    # the contents.
    license = licenses.unfree;
  };
}
