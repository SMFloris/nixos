{
  lib,
  stdenv,
  fetchFromGitHub,
  c3c,
}:

stdenv.mkDerivation rec {
  pname = "c3_ls";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "ManuLinares";
    repo = "c3_ls";
    rev = "v${version}";
    hash = "sha256-3swywEQZKPYFr5YZaLTCDPjeE2P8G7x/CmugC2g8NQE=";
  };

  nativeBuildInputs = [c3c];

  buildPhase = ''
    runHook preBuild
    c3c build -O2
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 build/c3_ls $out/bin/c3_ls
    runHook postInstall
  '';

  meta = with lib; {
    description = "Language server for the C3 programming language";
    homepage = "https://github.com/ManuLinares/c3_ls";
    license = licenses.mit;
    mainProgram = "c3_ls";
    platforms = platforms.linux;
  };
}
