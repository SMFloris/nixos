{ pkgs, lib, fetchurl, autoPatchelfHook }:

pkgs.stdenv.mkDerivation rec {  
  pname = "zot";
  version = "2.1.2";

  src = fetchurl {
    url = "https://github.com/project-zot/zot/releases/download/v${version}/zot-linux-amd64";
    hash = "sha256-TD7EoOLpAxLyz7vk6yj5+oV2ESowOIXv8S+67WBIYSU=";
  }; 

  dontUnpack = true;
  dontBuild = true;

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  installPhase = ''
    runHook preInstall
    install -m755 -D $src $out/bin/zot
    runHook postInstall
  '';

  meta = with lib; {
    description = "A scale-out production-ready vendor-neutral OCI-native container image/artifact registry (purely based on OCI Distribution Specification)";
    license = licenses.mit;
    maintainers = [ "Floris-Andrei Stoica-Marcu" ];
  };
}
