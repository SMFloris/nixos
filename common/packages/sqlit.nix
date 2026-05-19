{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "sqlit";
  version = "1.2.11";

  src = fetchFromGitHub {
    owner = "Maxteabag";
    repo = "sqlit";
    rev = "v${version}";
    sha256 = "sha256-zPkBdGq4PoAWonMq5FWGaz19QWiZsHuVQcW/45ynqq4=";
  };

  pyproject = true;

  build-system = [
    python3Packages.hatchling
    python3Packages.hatch-vcs
    python3Packages.setuptools-scm
  ];

  nativeBuildInputs = [
    python3Packages.pythonRelaxDepsHook
  ];

  pythonRelaxDeps = [
    "textual-fastdatatable"
  ];

  SETUPTOOLS_SCM_PRETEND_VERSION = version;

  dependencies = with python3Packages; [
    docker
    keyring
    pyperclip
    sqlparse
    textual
    textual-fastdatatable
    psycopg2-binary
    pymysql
    requests
  ];

  pythonImportsCheck = [ "sqlit" ];

  meta = with lib; {
    description = "A terminal UI for SQL databases";
    homepage = "https://github.com/Maxteabag/sqlit";
    license = licenses.mit;
    mainProgram = "sqlit";
  };
}
