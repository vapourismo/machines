{...}: {
  services.vault = {
    enable = true;
    storageBackend = "postgresql";
    extraSettingsPaths = ["/run/keys/vault-storage.hcl"];
  };

  users.users.vault.extraGroups = ["keys"];

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."alpha.vault.hwlium.com" = {
      enableACME = true;
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:8200/";
        extraConfig = ''
          proxy_ssl_server_name on;
        '';
      };
    };
  };
}
