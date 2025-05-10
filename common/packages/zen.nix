{ appimageTools, fetchurl }:
let
  pname = "zen";
  version = "1.9.1b";
in
appimageTools.wrapType2 {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen-x86_64.AppImage";
    hash = "sha256-OpdUeFzFAWi1ur2nKt4WSWJqj/J/4iigSmxMBCOGg+w=";
  };

}
