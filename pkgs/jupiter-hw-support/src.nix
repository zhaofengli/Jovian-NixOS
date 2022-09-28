{ fetchFromGitHub }:

let
  version = "20220927.1";
in (fetchFromGitHub {
  name = "jupiter-hw-support-${version}";
  owner = "Jovian-Experiments";
  repo = "jupiter-hw-support";
  rev = "jupiter-${version}";
  sha256 = "sha256-Tt11er2ZlTrij4d/yu530WhJ5KZTTmSaDISmv1apqJQ=";
}) // {
  inherit version;
}
