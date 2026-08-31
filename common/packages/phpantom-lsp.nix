{ lib, fetchurl, stdenv }:

stdenv.mkDerivation rec {
  pname = "phpantom-lsp";
  version = "0.9.0";

  src = fetchurl {
    url = "https://github.com/PHPantom-dev/phpantom_lsp/releases/download/${version}/phpantom_lsp-x86_64-unknown-linux-gnu.tar.gz";
    hash = "sha256-zt4K8YCrTWmAGUZZ5297IRBx3O9AxU8lBuPMeYTGM/k=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    tar -xzf $src
    install -Dm755 phpantom_lsp $out/bin/phpantom_lsp
    runHook postInstall
  '';

  meta = with lib; {
    description = "Fast PHP language server with deep type intelligence";
    homepage = "https://github.com/PHPantom-dev/phpantom_lsp";
    license = licenses.mit;
    mainProgram = "phpantom_lsp";
    platforms = [ "x86_64-linux" ];
  };
}
