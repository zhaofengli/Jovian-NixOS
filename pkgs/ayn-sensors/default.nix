{ lib, stdenv, fetchFromGitHub, kernel, pahole }:

stdenv.mkDerivation {
  pname = "ayn-sensors";
  version = "unstable-2023-08-23";

  src = fetchFromGitHub {
    owner = "ShadowBlip";
    repo = "ayn-platform";
    rev = "3fdfa48edf1046d507b9e62dfd246de9a31b10ac";
    hash = "sha256-cgMfqd+cmsPg1rEbVBU0D7OO+bZg44HlXMgU8IeshzI=";
  };

  buildInputs = [
    pahole
  ];

  buildPhase = ''
    runHook preBuild

    make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build M=$PWD modules

    ls -lah

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    moddir="$out/lib/modules/${kernel.modDirVersion}"
    mkdir -p $moddir

    install -m644 ayn-sensors.ko $moddir

    runHook postInstall
  '';
}
