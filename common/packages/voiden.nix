{
  lib,
  appimageTools,
  fetchurl,
}: let
  version = "1.6.3";
  pname = "voiden";

  src = fetchurl {
    url = "https://voiden.md/api/download/stable/linux/x64/Voiden-${version}.AppImage";
    hash = "sha256-1cR32d8M1/4YnXsFO0K8eI2mLQ2OnpDOH2i6TNx3Lxc=";
  };

  appimageContents = appimageTools.extractType1 {inherit pname version src;};
in
  appimageTools.wrapType2 rec {
    inherit pname version src;

    extraInstallCommands = ''
      install -m 444 -D ${appimageContents}/Voiden.desktop -t $out/share/applications
      substituteInPlace $out/share/applications/Voiden.desktop \
        --replace-fail 'Exec=Voiden --no-sandbox --disable-setuid-sandbox %u' 'Exec=voiden'
      cp -r ${appimageContents}/usr/share/icons $out/share
    '';

    extraBwrapArgs = [
      "--bind-try /etc/nixos/ /etc/nixos/"
    ];
    meta = {
      description = "Voiden api testing";
      homepage = "https://voiden.md/download";
      downloadPage = "https://voiden.md/download";
      license = lib.licenses.asl20;
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      maintainers = with lib.maintainers; [onny];
      platforms = ["x86_64-linux"];
    };
  }
