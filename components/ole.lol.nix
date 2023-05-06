{...}: {
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."nostr.ole.lol" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/nostr.ole.lol";
      extraConfig = ''
        add_header 'Access-Control-Allow-Origin' '*';
      '';

      locations."= /" = {
        return = "301 https://ole.lol";
      };
    };
  };
}
