<div align="center"><h1>Jovian NixOS</h1></div>
<div align="center"><strong><em>NixOS on the Steam Deck</em></strong></div>

****

A set of packages and configurations for running NixOS on the [Steam Deck](https://www.steamdeck.com).
This repo is also useful for obtaining a Deck-like experience on other `x86_64` devices.

Installation
------------

Use [the normal installation images](https://nixos.org/download.html#download-nixos) available on NixOS.org.

Prefer the `nixos-unstable` image, but you can also use the latest stable image as long as you use the `unstable` channel for the system.

When configuring the system, import `./modules` from this repo in your configuration.

### Steam Deck

To enter the boot menu, power off the Steam Deck then hold down `Volume-` and tap the `Power` button.

When configuring the system, import `./modules` from this repo in your configuration and enable the Steam Deck-specific hardware configurations with `jovian.devices.steamdeck.enable = true;`.

### Other Devices

No other device-specific quirks or configuration handled for now.

Feel free to contribute one or more!

Configuration
-------------

All available module options along with their descriptions can be found under `modules`.

To use the Steam Deck UI, set `jovian.steam.enable = true;` in your configuration.
Then you can start the UI using one of the following methods:

- Select "Gaming Mode" in the Display Manager or run `steam-session` in a VT.
- Launch `steam-session` within an existing desktop session. This will run [gamescope](https://github.com/Plagman/gamescope) in nested mode which results in higher latency.

Firmware Updates
----------------

### BIOS

Run `sudo fwupdmgr update` to update the BIOS with fwupd.
We [repackage](./pkgs/jupiter-hw-support/bios-fwupd.nix) the vendor update as a fwupd update package.

Alternatively, the `steamdeck-firmware` package provides the original vendor updater as the `jupiter-biosupdate` command.

### Controller

Run `jupiter-controller-update` in the `steamdeck-firmware` package to update.

### Docking Station

Updates to the Docking Station firmware are available in the `jupiter-dock-updater-bin` package.
Connect to the dock via USB-C and run `jupiter-dock-updater` to update.

FAQs
----

> **Jovian**
> “Relating to [...] Jupiter or the class of [...] which Jupiter belongs.”

> What's Jupiter?

[There's a disambiguation page that won't help you](https://en.wikipedia.org/wiki/Jupiter_(disambiguation)).
I don't know *exactly* what it's the codename for.
It is either the codename for the Steam Deck, or the codename for the new Steam OS for the Steam Deck.
Things get awfully murky when you realize that *Neptune*'s also a thing, and it's unclear really from the outside, and quick searches don't provide *conclusive* evidence.
But to the best of my knowledge, Jupiter is the OS for us.

> What channels are supported?

Truthfully, no channel is *supported*, but the older the stable release was cut, the more likely the additions from Jovian NixOS won't work as expected.

Thus, it is preferrable to use `nixos-unstable`. The latest update *should* work fine, and when it doesn't, it'll be handled soon enough.

* * *

Importing the modules in your configuration
-------------------------------------------

One way to do so is by using `fetchTarball` in the `imports` of your configuration.

```nix
{ config, lib, pkgs, ... }:

{
  imports = [
    (
      # Put the most recent revision here:
      let revision = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"; in
      builtins.fetchTarball {
        url = "https://github.com/Jovian-Experiments/Jovian-NixOS/archive/${revision}.tar.gz";
        # Update the hash as needed:
        sha256 = "sha256:0000000000000000000000000000000000000000000000000000";
      } + "/modules"
    )

  /* ... */
  ];

  /* ... */
}
```

Another way is to use *Flakes*, or any other method to fetch inputs.

When hacking on Jovian NixOS things, adding the path to a Git checkout of this repo to `imports` works well too.
