# Steam

```admonish info
This is an example of a topic page containing sample configs, troubleshooting steps, as well as topic-specific options.
```

You can enable the Steam Deck version of the Steam client with:

```nix
{
  jovian.steam.enable = true;
}
```

To manually start **Gaming Mode** (also known as the **Steam Deck UI**), there are two options:

- Select "Gaming Mode" in the Display Manager or run `steam-session` in a VT.
- Launch `steam-session` within an existing desktop session. This will run [gamescope](https://github.com/Plagman/gamescope) in nested mode which results in higher latency.

## Start On Boot

To automatically launch Gaming Mode on boot and enable desktop switching from the power menu:

```nix
{
  services.xserver.desktopManager.plasma5.enable = true;

  jovian.steam = {
    enable = true;
    autoStart = true;
    user = "yourname";
    desktopSession = "plasma";
  };
}
```

```admonish warning
Add text here
```

## Troubleshooting

Logs from Gaming Mode can be obtained with:

```bash
journalctl --user -u steam-session.slice
```

## Options

<!-- The following is injected by the build system -->
