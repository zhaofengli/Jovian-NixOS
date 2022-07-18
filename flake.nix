{
  description = "NixOS on Steam Deck";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    pkgs = import nixpkgs {
      system = "x86_64-linux";
      overlays = [
        self.overlay
      ];
    };
  in {
    # Minimize diff while making `nix flake check` pass
    overlay = final: prev: (import ./overlay.nix) final prev;

    legacyPackages.x86_64-linux = pkgs;

    nixosModules.jovian = import ./modules;
  };
}
