self: super: {
  c3c = super.c3c.overrideAttrs (oldAttrs: {
    version = "0.7.1";
    checkPhase = ''
        runHook preCheck
        ( cd ../resources/testproject; ../../build/c3c build --trust=full )
        ( cd ../test; ../build/c3c compile-run -O1 src/test_suite_runner.c3 -- ../build/c3c test_suite )
        runHook postCheck
    '';
    src = super.fetchFromGitHub {
      owner = "c3lang";
      repo = "c3c";
      rev = "refs/tags/v0.7.1";
      sha256 =  "sha256-2nTFQNoSAdD12BiwWMtrD9SeelTUOM3DYUdjBSjWnVU=";
    };
  });
}
