{ 
  decky-loader,
  fetchFromGitHub,
  pnpm,
}:
decky-loader.overridePythonAttrs rec {
  pname = "decky-loader";
  version = "3.0.4-pre1";

  src = fetchFromGitHub {
    owner = "SteamDeckHomebrew";
    repo = "decky-loader";
    rev = "v${version}";
    hash = "sha256-pWkAu0nYg3YOA7w/8eN9n23sSyFkZcuvGUF8Swd0Hbc=";
  };

  pnpmDeps = pnpm.fetchDeps {
    inherit pname version src;
    sourceRoot = "${src.name}/frontend";
    hash = "sha256-l4AA3xOdouk08i9n0lWbzeKCTqEkXC0BOsW1uxQMPyo=";
  };
}
