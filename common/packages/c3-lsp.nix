{
  lib,
  stdenv,
  fetchFromGitHub,
  c3c,
}:

stdenv.mkDerivation rec {
  pname = "c3-lsp";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "tonis2";
    repo = "lsp";
    rev = "v${version}";
    hash = "sha256-ntO+xJB0l2O2zJxR1r4lsYTkzW8TFjSqKdB9yasKfFg=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [c3c];

  buildPhase = ''
    runHook preBuild
    c3c build lsp
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 build/lsp $out/bin/c3-lsp
    runHook postInstall
  '';

  meta = with lib; {
    description = "Language server for the C3 programming language";
    homepage = "https://github.com/tonis2/lsp";
    license = licenses.mit;
    mainProgram = "c3-lsp";
    platforms = platforms.linux;
  };
}
