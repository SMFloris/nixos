{
  pkgs,
  ...
}: let
  site = pkgs.runCommand "alpha-homebank-site" {} ''
    mkdir -p "$out"
    cp ${/home/flow/Projects/caca_ing/index.html} "$out/index.html"
    cp ${/home/flow/Projects/caca_ing/raport-tranzactii.csv} "$out/raport-tranzactii.csv"
  '';
in {
  networking.firewall.allowedTCPPorts = [443];

  services.nginx = {
    enable = true;
    virtualHosts."alpha.homebank.ro" = {
      root = site;
      onlySSL = true;
      listen = [
        {
          addr = "0.0.0.0";
          port = 443;
          ssl = true;
        }
      ];
      sslCertificate = "/etc/nixos/certs/alpha-homebank-server.crt";
      sslCertificateKey = "/etc/nixos/certs/alpha-homebank-server.key";
      locations."/".tryFiles = "$uri $uri/ /index.html";
      extraConfig = ''
        add_header Cache-Control "no-store" always;
      '';
    };
  };

  systemd.tmpfiles.rules = [
    "z /etc/nixos/certs/alpha-homebank-server.key 0640 flow nginx -"
  ];
}
