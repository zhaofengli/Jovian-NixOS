{ lib, stdenv, python3 }:
let
  pythonEnv = python3.withPackages (py: with py; [
    evdev
  ]);
in stdenv.mkDerivation {
  name = "jovian-power-button-handler";

  src = ./power-button-handler.py;

  buildInputs = [ pythonEnv ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r $src $out/bin/power-button-handler

    runHook postInstall
  '';

  meta = with lib; {
    description = ''
      Power button handler

      Modified from power-button-handler.py in jupiter-hw-support to allow
      specifying the power button device.
    '';
    license = licenses.mit;
  };
}

