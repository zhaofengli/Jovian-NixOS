{
  description = "NixOS on Steam Deck";

  inputs = {
    nixpkgs.url = "github:zhaofengli/nixpkgs/zhaofeng-22.11";
  };

  outputs = { self, nixpkgs }: let
    pkgs = import nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
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
