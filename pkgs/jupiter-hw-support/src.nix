{ fetchFromGitHub }:

let
  version = "20220810.1";
in (fetchFromGitHub {
  name = "jupiter-hw-support-${version}";
  owner = "Jovian-Experiments";
  repo = "jupiter-hw-support";
  rev = "jupiter-${version}";
  sha256 = "sha256-9FDpMPN2SnbemOo9HseM/xzb/qV0esm1APewVzLt7no=";
}) // {
  inherit version;
}
