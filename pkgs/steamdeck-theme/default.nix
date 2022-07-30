{ lib, stdenv, python3, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "steamdeck-theme";
  version = "0.11";

  # TODO: Replace with https://gitlab.steamos.cloud/jupiter/steamdeck-kde-presets
  # once it becomes public
  src = fetchFromGitHub {
    name = "steamdeck-kde-presets-${version}";
    owner = "Jovian-Experiments";
    repo = "steamdeck-kde-presets";
    rev = version;
    sha256 = "sha256-rolekomsjHoqgDE5n1tx6g6uIOgbFK9zFoapmVLuA2w=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share
    cp -r usr/share/{color-schemes,konsole,plasma,themes,wallpapers} $out/share

    # other icons (install-firefox, distributor-logo) are not applicable to NixOS
    mkdir -p $out/share/icons/hicolor/scalable/actions
    cp usr/share/icons/hicolor/scalable/actions/* $out/share/icons/hicolor/scalable/actions

    runHook postInstall
  '';

  meta = with lib; {
    description = "Steam Deck theme";
    license = licenses.gpl2;
  };
}
