{config, ...}: {
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."ole.lol" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/ole.lol";
    };
  };
}
