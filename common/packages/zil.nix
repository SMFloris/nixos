{ pkgs, lib, fetchurl, autoPatchelfHook }:

pkgs.stdenv.mkDerivation rec {  
  pname = "zil";
  version = "2.1.2";

  src = fetchurl {
    url = "https://github.com/project-zot/zot/releases/download/v${version}/zli-linux-amd64";
    hash = "sha256-FxZazQcYcJrd8oCjPO2NIg0OPil6q2ka3HCROzPMwVE=";
  }; 

  dontUnpack = true;
  dontBuild = true;

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  installPhase = ''
    runHook preInstall
    install -m755 -D $src $out/bin/zil
    runHook postInstall
  '';

  meta = with lib; {
    description = "A CLI client for zot";
    license = licenses.mit;
    maintainers = [ "Floris-Andrei Stoica-Marcu" ];
  };
}
