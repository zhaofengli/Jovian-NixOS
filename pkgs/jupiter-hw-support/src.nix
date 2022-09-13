{ fetchFromGitHub }:

let
  version = "20220912.1";
in (fetchFromGitHub {
  name = "jupiter-hw-support-${version}";
  owner = "Jovian-Experiments";
  repo = "jupiter-hw-support";
  rev = "jupiter-${version}";
  sha256 = "sha256-eFr/mdSiLMKKExQoHaR+jJBSJaW0T4NOeJx3+5sFqO4=";
}) // {
  inherit version;
}
