{ lib, stdenv, nix-gitignore, mdbook, mdbook-admonish
, callPackage, writeScript
}:
let
  options = callPackage ./eval-options.nix { };

  makeDoc = category: let
    filteredOptions = if category != null then {
      jovian.${category} = options.jovian.${category};
    } else {
      inherit (options) jovian;
    };
  in callPackage ./options-doc.nix {
    options = filteredOptions;
  };

  emitDocs = file: category: let
    markdown = (makeDoc category).optionsCommonMark;
  in ''
    cat "${markdown}" | sed "s|##|###|g" >>src/${file}
  '';
in stdenv.mkDerivation {
  name = "jovian-book";

  src = nix-gitignore.gitignoreSource [] ./.;

  nativeBuildInputs = [ mdbook mdbook-admonish ];

  buildPhase = ''
    runHook preBuild

    ${emitDocs "options.md" null}
    ${emitDocs "steam.md" "steam"}

    mdbook build -d $out

    runHook postBuild
  '';

  dontInstall = true;
}
