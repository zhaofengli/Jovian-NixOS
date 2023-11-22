{ lib, stdenv, fetchFromGitHub, kernel, pahole }:

stdenv.mkDerivation {
  pname = "ayn-platform";
  version = "unstable-2023-10-07";

  src = fetchFromGitHub {
    owner = "ShadowBlip";
    repo = "ayn-platform";
    rev = "068cce29a7ef31f32b6aed3ca8ab9c1c91308e41";
    hash = "sha256-759lG6OLe25lKiGAskl1+4w3ZuoDkFymnLjYahFlQ+k=";
  };

  buildInputs = [
    pahole
  ];

  buildPhase = ''
    runHook preBuild

    make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build M=$PWD modules

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    moddir="$out/lib/modules/${kernel.modDirVersion}"
    mkdir -p $moddir

    install -m644 ayn-platform.ko $moddir

    runHook postInstall
  '';
}
