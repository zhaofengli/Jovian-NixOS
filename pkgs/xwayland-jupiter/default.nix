# Xwayland with SteamOS 3.x patches to better integrate with gamescope
#
# Differences from upstream: <https://github.com/freedesktop/xorg-xserver/compare/master...Jovian-Experiments:xserver:jupiter-20220831>

{ lib, xwayland, fetchFromGitHub, udev, xorg }:

xwayland.overrideAttrs (old: rec {
  pname = "xwayland-jupiter";
  version = "jupiter-20220831";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "xorg-xserver";
    rev = version;
    hash = "sha256-tg57oe/TMkyR6TQJcLsCXMqM/zfo6gUeHxKpJwivsvA=";
  };

  buildInputs = old.buildInputs ++ [ udev xorg.libpciaccess ];
})
