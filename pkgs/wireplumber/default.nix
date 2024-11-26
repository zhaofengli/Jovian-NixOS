{ wireplumber', fetchFromGitHub }:
wireplumber'.overrideAttrs(_: {
  version = "0.5.6";

  src = fetchFromGitHub {
    owner = "Jovian-Experiments";
    repo = "wireplumber";
    rev = "0.5.6-jupiter1.2";
    hash = "sha256-Zq+btS/cFQ9WHpcXf5MO1e/jfZRvozrpb49W1LVNk3E=";
  };
})
