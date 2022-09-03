{ fetchFromGitHub }:

let
  version = "20220830.1";
in (fetchFromGitHub {
  name = "jupiter-hw-support-${version}";
  owner = "Jovian-Experiments";
  repo = "jupiter-hw-support";
  rev = "jupiter-${version}";
  sha256 = "sha256-EziPOJdN/C0xsZnqWcJuiYVse7/Di1VkyP63MLTZ8p4=";
}) // {
  inherit version;
}
