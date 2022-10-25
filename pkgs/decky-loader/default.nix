{ lib
, stdenv
, fetchFromGitHub
, nodePackages
, python3
}:

let
  version = "2.3.1-pre1";
  rev = "v${version}";
  sha256 = "sha256-3++h+G1w8nzDQ58Fp9+qxdSXZiGQHGMcVMX3AxoAN/4=";
  npmSha256 = "sha256-KVMicNdOS2GmAokBICLVOjP4bijQ6RdKP5Hn3eHHwd0=";

  pythonEnv = python3.withPackages (py: with py; [
    aiohttp
    aiohttp-jinja2
    aiohttp-cors
    watchdog
    certifi
  ]);

  src = fetchFromGitHub rec {
    name = "decky-loader-${rev}";
    owner = "SteamDeckHomebrew";
    repo = "decky-loader";
    inherit rev sha256;
  };

  frontendDeps = stdenv.mkDerivation {
    name = "decky-loader-frontend-deps-${version}.tar.gz";
    inherit src;

    nativeBuildInputs = [ nodePackages.pnpm ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild

      export SOURCE_DATE_EPOCH=1
      cd frontend
      pnpm i --ignore-scripts --ignore-pnpmfile --frozen-lockfile

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      rm node_modules/.modules.yaml
      tar -czf $out --owner=0 --group=0 --numeric-owner --format=gnu \
        --mtime="@$SOURCE_DATE_EPOCH" --sort=name \
        node_modules

      runHook postInstall
    '';

    outputHashMode = "flat";
    outputHashAlgo = "sha256";
    outputHash = npmSha256;
  };

  frontend = stdenv.mkDerivation {
    pname = "decky-loader-frontend";
    inherit version src;

    nativeBuildInputs = [ nodePackages.pnpm ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild

      pushd frontend
      tar xf ${frontendDeps}
      ls -lah node_modules/
      pnpm build
      popd

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      cp -r backend/static $out

      runHook postInstall
    '';
  };

  loader = stdenv.mkDerivation {
    pname = "decky-loader";
    inherit version src;

    buildInputs = [ pythonEnv ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib
      cp -r backend $out/lib/decky-loader

      ln -s ${frontend} $out/lib/decky-loader/static

      mkdir $out/bin
      cat << EOF >$out/bin/decky-loader
      #!/bin/sh
      exec ${pythonEnv}/bin/python3 $out/lib/decky-loader/main.py
      EOF
      chmod +x $out/bin/decky-loader

      runHook postInstall
    '';
  };

in loader
