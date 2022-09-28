# Xwayland with SteamOS 3.x patches to better integrate with gamescope
#
# Differences from upstream: <https://github.com/mirror/xserver/compare/master...Jovian-Experiments:xserver:jupiter-20220831>

{ lib, xwayland, fetchpatch }:

let
  jupiterPatch = commit: hash: fetchpatch {
    name = "${commit}.patch";
    url = "https://github.com/Jovian-Experiments/xorg-xserver/commit/${commit}.patch";
    inherit hash;
  };
in xwayland.overrideAttrs (old: {
  pname = "xwayland-jupiter";
  patches = (old.patches or []) ++ [
    # xwayland: Add XWAYLAND_FORCE_ENABLE_EXTRA_MODES env var
    (jupiterPatch "5f5f02299c2d4bbd0ef79540645d162fdbf34a59" "sha256-MJ2Ck1mhZov0drwssbdnAQvZHw3gljuKbma2r7H1PDU=")
    # xwayland: Add some more xwayland fake modes
    (jupiterPatch "c838945c6df5a30f5d3f179b3eee32d7e30b7951" "sha256-sN6Tjdn5I5Gc3OHUKbXGYQ8PXIqXcjxrF7SmjO5Frgs=")
    # xwayland: Avoid useless blits for dummy windows
    (jupiterPatch "ce24a12130189d36f3b77dbc74d7b1d116f870f5" "sha256-b8/1fH817UkXVl8RcL0pJHIRKILM3izju2PssHEQbaA=")
    # xwayland: Implement tearing protocol
    (jupiterPatch "1d653e26459c6ae7b751c17bf83bd08c8b8c87b6" "sha256-oTr/dLlNcKgq4RROkfpG4ytIS9EyAj+jBsk8CCVZ3Hk=")
    # Use gamescope tearing protocol instead
    (jupiterPatch "d4d883ad5c76537a6c9b1617cd45ce10df26575c" "sha256-OFpNcnVAxavP2COXsqfiF4lXXetZrxPqnnIc89hk7Uo=")
  ];

  # Use gamescope tearing protocol instead
  postPatch = (old.postPatch or "") + ''
    mv hw/xwayland/protocols/unstable/tearing-control/{,gamescope-}tearing-control-unstable-v1.xml
  '';
})
