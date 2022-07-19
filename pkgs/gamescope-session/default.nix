{ lib, stdenv
, steam
, gamescope
, mangohud
, jupiter-hw-support
, writeShellScriptBin
}:

let
  # The sudo wrapper doesn't work in FHS environments. For our purposes
  # we add a dummy sudo command that does not actually escalate privileges.
  #
  # <https://github.com/NixOS/nixpkgs/issues/42117>
  dummySudo = writeShellScriptBin "sudo" ''
    declare -a final

    positional=""
    for value in "$@"; do
      if [[ -n "$positional" ]]; then
        final+=("$value")
      elif [[ "$value" == "-n" ]]; then
        :
      else
        positional="y"
        final+=("$value")
      fi
    done

    exec "''${final[@]}"
  '';

  # Dummy SteamOS updater that does nothing
  #
  # This gets us past the OS update step in the OOBE wizard.
  dummyOsUpdater = writeShellScriptBin "steamos-update" ''
    >&2 echo "dummy steamos-update"
    exit 7;
  '';

  # Dummy Steam Deck BIOS updater that does nothing
  dummyBiosUpdater = writeShellScriptBin "jupiter-biosupdate" ''
    >&2 echo "dummy jupiter-biosupdate"
  '';

  wrappedSteam = steam.override {
    extraPkgs = pkgs: [
      dummyOsUpdater dummyBiosUpdater
    ];
    extraProfile = ''
      export PATH=${dummySudo}/bin:$PATH
    '';
  };

  binPath = lib.makeBinPath [ wrappedSteam gamescope mangohud ];
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
