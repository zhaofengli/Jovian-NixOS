{ fetchFromGitHub }:

let
  version = "20220727.1";
in (fetchFromGitHub {
  owner = "Jovian-Experiments";
  repo = "jupiter-hw-support";
  rev = "jupiter-${version}";
  sha256 = "sha256-dtt4ZeXEzGafskMVmhl/wH8XQsWSqfi0u65yMddylzY=";
}) // {
  inherit version;
}
