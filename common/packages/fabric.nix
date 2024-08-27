{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "fabric-ai";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "danielmiessler";
    repo = "fabric";
    rev = "v${version}";
    sha256 = "sha256-cCptzSC0wiWwS7t6U9sWlkNlJcMtFcgO8IaHgwq1fpw=";
  };

  vendorHash = null;

  preBuild = ''
      GOPROXY=proxy.golang.org go mod vendor
  '';

  meta = with lib; {
    description = "fabric is an open-source framework for augmenting humans using AI. It provides a modular framework for solving specific problems using a crowdsourced set of AI prompts that can be used anywhere.";
    license = licenses.mit;
    maintainers = [ "Floris-Andrei Stoica-Marcu" ];
  };
}
