{
  config,
  pkgs,
  ...
}: {
  services.elasticsearch = {
    enable = true;
    package = pkgs.elasticsearch7;
  };

  services.kibana = {
    enable = true;
    package = pkgs.kibana7;
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."alpha.elasticsearch.hwlium.com" = {
      enableACME = true;
      forceSSL = true;

      extraConfig = ''
        ssl_client_certificate ${../data/mtls.hwlium.com-intermediate.pem};
        ssl_verify_client on;
      '';

      locations."/" = {
        proxyPass = "http://127.0.0.1:${builtins.toString config.services.elasticsearch.port}/";
        extraConfig = ''
          if ($ssl_client_verify != SUCCESS) {
            return 403;
          }

          proxy_ssl_server_name on;
        '';
      };
    };

    virtualHosts."alpha.kibana.hwlium.com" = {
      enableACME = true;
      forceSSL = true;

      basicAuthFile = "/run/keys/kibana-basic";

      locations."/" = {
        proxyPass = "http://127.0.0.1:${builtins.toString config.services.kibana.port}/";
        extraConfig = ''
          proxy_ssl_server_name on;
        '';
      };
    };
  };

  users.users.nginx.extraGroups = ["keys"];

  services.filebeat = {
    enable = true;
    package = pkgs.filebeat7;

    inputs = {
      journald.id = "everything";
    };
  };
}
