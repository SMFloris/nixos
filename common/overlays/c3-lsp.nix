self: super: {
  c3-lsp = super.c3-lsp.overrideAttrs (oldAttrs: {
    version = "0.4.0";
    src = super.fetchFromGitHub {
      owner = "pherrymason";
      repo = "c3-lsp";
      rev = "refs/tags/v0.4.0";
      sha256 =  "sha256-7Dmd7gjZ05WH4Og9ZkRPJKyaShBrm+i7J8eT10yshEs=";
    };
    vendorHash = "sha256-eT+Qirl0R1+di3JvXxggGK/nK9+nqw+8QEur+ldJXSc=";
  });
}
