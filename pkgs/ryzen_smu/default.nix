{ lib, stdenv, fetchFromGitLab, kernel, pahole }:

stdenv.mkDerivation rec {
  pname = "ryzen_smu";
  version = "0.1.5";

  src = fetchFromGitLab {
    owner = "leogx9r";
    repo = "ryzen_smu";
    rev = "v${version}";
    hash = "sha256-n4uWikGg0Kcki/TvV4BiRO3/VE5M6/KopPncj5RQFAQ=";
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

    ls -lah
    install -m644 ryzen_smu.ko $moddir

    runHook postInstall
  '';
}
