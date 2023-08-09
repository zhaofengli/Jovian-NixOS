{ lib, nixos, nixosOptionsDoc
, options
, sourceLinkPrefix ? "https://github.com/Jovian-Experiments/Jovian-NixOS/blob/development"
}:
nixosOptionsDoc {
  inherit options;

  # Adapted from nixpkgs/nixos/doc/manual/default.nix
  transformOptions = opt: opt // {
    declarations = map (decl:
      if lib.hasPrefix (toString ../.) (toString decl)
      then
        let subpath = lib.removePrefix "/" (lib.removePrefix (toString ../.) (toString decl));
        in { url = "${sourceLinkPrefix}/${subpath}"; name = subpath; }
        else decl
    ) opt.declarations;
  };
}
