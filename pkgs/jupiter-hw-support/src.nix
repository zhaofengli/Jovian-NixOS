{ fetchFromGitHub }:

let
  version = "20220721.3";
in (fetchFromGitHub {
  owner = "Jovian-Experiments";
  repo = "jupiter-hw-support";
  rev = "jupiter-${version}";
  sha256 = "sha256-uJZMFxiDcmzkLOp6NXHfRL4FBZbCkau5A/snW4j2Zrg=";
}) // {
  inherit version;
}
