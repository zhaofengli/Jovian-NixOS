{ linux-firmware, fetchFromGitHub }:

linux-firmware.overrideAttrs(_: {
  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "linux-firmware";
    rev = "jupiter-20221209-rtw-debug";
    hash = "sha256-TbEcgZgxv4BvEgNSM62tLYQVK1hakZ7Q62po+4HQ+Os=";
  };

  outputHash = "sha256-hblyEJP9Jitrgt7vMDq5sQigLSKuq32m8T3DwmVQDnQ=";
})
