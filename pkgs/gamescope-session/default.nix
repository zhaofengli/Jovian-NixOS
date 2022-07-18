{ lib, stdenv
, steam
, gamescope
, mangohud
, jupiter-hw-support
}:

let
  binPath = lib.makeBinPath [ steam gamescope mangohud ];
in stdenv.mkDerivation {
  name = "gamescope-session";
  src = ./gamescope-session;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    path=${binPath} hwsupport=${jupiter-hw-support} \
      substituteAll $src $out/bin/gamescope-session

    chmod +x $out/bin/gamescope-session
  '';
}
