{ lib, stdenv, fetchFromGitHub, ncurses }:

stdenv.mkDerivation {
  pname = "sdgyrodsu";
  version = "1.14";

  src = fetchFromGitHub {
    owner = "zhaofengli";
    repo = "SteamDeckGyroDSU";
    rev = "0837755fd61397e8de68f88d97ed4cbf048fb68e";
    sha256 = "sha256-ZVvUIBUJ5G0yfUIKTdBYSlhFyMWP9U7eUTdsTMJAgrA=";
  };

  buildInputs = [ ncurses ];

  makeFlags = [ "NOPREPARE=1" "release" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r bin/release/sdgyrodsu $out/bin

    runHook postInstall
  '';

  meta = with lib; {
    description = "Cemuhook DSU server for the Steam Deck Gyroscope";
    homepage = "https://github.com/kmicki/SteamDeckGyroDSU";
    license = licenses.mit;
  };
}
