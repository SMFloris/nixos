{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  gobject-introspection,
  makeWrapper,
  wrapGAppsHook3,
  python3,
  gtk3,
}:

let
  python = python3.withPackages (pythonPackages: with pythonPackages; [
    dbus-python
    pygobject3
  ]);
in
stdenvNoCC.mkDerivation rec {
  pname = "mx4ctl";
  version = "0.6.0-unstable-2026-09-10";

  src = fetchFromGitHub {
    owner = "A-Common-Guy";
    repo = "mx4_linux";
    rev = "a65427fe31dc2b7231fe92cd6a613db7d17e5d9d";
    hash = "sha256-yakUxmQ1Wh7ZFA0PK5JB9pz7i7Xf4oOatR6qaSsM+VE=";
  };

  nativeBuildInputs = [
    gobject-introspection
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = [ gtk3 ];

  dontBuild = true;
  dontWrapGApps = true;

  postPatch = ''
    substituteInPlace mx4/uinput.py \
      --replace-fail 'KEY_ESC = 1' $'KEY_ESC = 1\nKEY_W = 17\nKEY_A = 30\nKEY_LEFT = 105\nKEY_RIGHT = 106' \
      --replace-fail 'ALL_KEYS = (KEY_ESC,' 'ALL_KEYS = (KEY_ESC, KEY_W, KEY_A, KEY_LEFT, KEY_RIGHT,'
    substituteInPlace mx4/daemon.py \
      --replace-fail '"overview": (uinput.KEY_LEFTMETA,),' \
                     $'"overview": (uinput.KEY_LEFTMETA,),\n    "applications": (uinput.KEY_LEFTMETA, uinput.KEY_A),\n    "windows": (uinput.KEY_LEFTMETA, uinput.KEY_W),\n    "workspace-left": (uinput.KEY_LEFTMETA, uinput.KEY_LEFT),\n    "workspace-right": (uinput.KEY_LEFTMETA, uinput.KEY_RIGHT),' \
      --replace-fail '"overview": "xdotool key super",' \
                     $'"overview": "xdotool key super",\n    "applications": "xdotool key super+a",\n    "windows": "xdotool key super+w",\n    "workspace-left": "xdotool key super+Left",\n    "workspace-right": "xdotool key super+Right",'
    substituteInPlace config.example.ini \
      --replace-fail '@workspace-prev @workspace-next @overview @show-desktop @minimize' \
                     '@workspace-prev @workspace-next @workspace-left @workspace-right @overview @applications @windows @show-desktop @minimize'
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 mx4ctl $out/bin/mx4ctl
    install -Dm755 mx4-wizard $out/bin/mx4-wizard
    install -Dm644 mx4/*.py -t $out/lib/mx4ctl/mx4
    install -Dm644 config.example.ini $out/share/mx4ctl/config.example.ini
    install -Dm644 README.md $out/share/doc/mx4ctl/README.md

    substituteInPlace $out/bin/mx4ctl $out/bin/mx4-wizard \
      --replace-fail 'pathlib.Path("/usr/lib/mx4ctl")' 'pathlib.Path("'$out'/lib/mx4ctl")'
    substituteInPlace $out/lib/mx4ctl/mx4/daemon.py \
      --replace-fail 'Path("/usr/share/mx4ctl/config.example.ini")' \
                     'Path("'$out'/share/mx4ctl/config.example.ini")'
    substituteInPlace $out/bin/mx4-wizard \
      --replace-fail 'PACKAGED_RULE = "/usr/lib/udev/rules.d/42-mx4ctl.rules"' \
                     'PACKAGED_RULE = "'$out'/lib/udev/rules.d/42-mx4ctl.rules"'

    install -Dm644 /dev/stdin $out/lib/udev/rules.d/42-mx4ctl.rules <<'EOF'
    ACTION=="add", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="046d", MODE="0660", TAG+="uaccess"
    ACTION=="add", SUBSYSTEM=="hidraw", KERNELS=="0005:046D:*", MODE="0660", TAG+="uaccess"
    KERNEL=="uinput", SUBSYSTEM=="misc", MODE="0660", TAG+="uaccess", OPTIONS+="static_node=uinput"
    ACTION=="add", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="046d", TAG+="systemd", ENV{SYSTEMD_USER_WANTS}+="mx4ctl-restore.service"
    EOF

    runHook postInstall
  '';

  preFixup = ''
    wrapGApp $out/bin/mx4ctl \
      --prefix PYTHONPATH : $out/lib/mx4ctl \
      --prefix PATH : ${lib.makeBinPath [ python ]}
    wrapGApp $out/bin/mx4-wizard \
      --prefix PYTHONPATH : $out/lib/mx4ctl \
      --prefix PATH : ${lib.makeBinPath [ python ]}
  '';

  meta = {
    description = "Logitech MX Master 4 haptics and extras for Linux";
    homepage = "https://github.com/A-Common-Guy/mx4_linux";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "mx4ctl";
  };
}
