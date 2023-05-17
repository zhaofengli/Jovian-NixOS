{ fetchFromGitHub }:

let
  version = "20230516.1";
in (fetchFromGitHub {
  name = "jupiter-hw-support-${version}";
  owner = "Jovian-Experiments";
  repo = "jupiter-hw-support";
  rev = "${version}";
  sha256 = "sha256-g7yH+sdqVE25UslD/zKRV4vcqcq8IZhuy8/hFfmRpVU=";
}) // {
  inherit version;
}
