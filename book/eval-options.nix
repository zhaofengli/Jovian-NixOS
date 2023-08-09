{ lib, nixos }:
let
  suppressModuleArgsDocs = { lib, ... }: {
    options = {
      _module.args = lib.mkOption {
        internal = true;
      };
    };
  };
  eval = nixos {
    imports = [ ../modules suppressModuleArgsDocs ];
  };
in eval.options
