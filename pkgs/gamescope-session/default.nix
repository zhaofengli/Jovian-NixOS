{ lib
, runCommand
, steam
, gamescope
, mangohud
, jupiter-hw-support
, steamdeck-theme
, writeShellScriptBin
}:

# TODO: Integrate this into modules/steam.nix. gamescope-session can be run on an
# existing desktop, in which case gamescope will be started in nested mode.

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

  # A very simplistic "session switcher." All it does is kill gamescope.
  sessionSwitcher = writeShellScriptBin "steamos-session-select" ''
    session="''${1:-gamescope}"

    >>~/gamescope.log echo "steamos-session-select: switching to $session"

    if [[ "$session" != "plasma" ]]; then
      >&2 echo "!! Unsupported session '$session'"
      >&2 echo "Currently this can only be called by Steam to switch to Desktop Mode"
      exit 1
    fi

    mkdir -p ~/.local/state
    >~/.local/state/steamos-session-select echo "$session"

    if [[ -n "$gamescope_pid" ]]; then
      kill "$gamescope_pid"
    else
      >&2 echo "!! Don't know how to kill gamescope"
      exit 1
    fi
  '';

  wrappedSteam = steam.override {
    extraPkgs = pkgs: [
      dummyOsUpdater dummyBiosUpdater
      sessionSwitcher
    ];
    extraProfile = ''
      export PATH=${dummySudo}/bin:$PATH
    '';
    extraArgs = "-steamdeck";
  };

  binPath = lib.makeBinPath [ wrappedSteam wrappedSteam.run gamescope mangohud ];
in runCommand "gamescope-session" {
  passthru.steam = wrappedSteam;
  passthru.providedSessions = [ "gamescope-wayland" ];
} ''
  mkdir -p $out/bin
  path=${binPath} hwsupport=${jupiter-hw-support} theme=${steamdeck-theme}\
    substituteAll ${./gamescope-session} $out/bin/gamescope-session
  chmod +x $out/bin/gamescope-session

  mkdir -p $out/share/wayland-sessions
  substituteAll ${./gamescope-wayland.desktop.in} $out/share/wayland-sessions/gamescope-wayland.desktop
''
