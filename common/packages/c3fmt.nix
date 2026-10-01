{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "c3fmt";
  version = "0.3.3";

  src = fetchurl {
    url = "https://github.com/lmichaudel/c3fmt/releases/download/v${finalAttrs.version}/c3fmt-linux";
    hash = "sha256-TbtpNy1L2WlXMqxc0B8PTeOtt98b64xQzJdGWpNaKCA=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/c3fmt"
    runHook postInstall
  '';

  meta = {
    description = "Customizable code formatter for the C3 language";
    homepage = "https://github.com/lmichaudel/c3fmt";
    license = lib.licenses.mit;
    mainProgram = "c3fmt";
    platforms = [ "x86_64-linux" ];
  };
})
