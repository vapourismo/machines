{
  config,
  pkgs,
  lib,
  ...
}: {
  security.acme.acceptTerms = true;

  security.acme.certs."alpha.database.hwlium.com" = {
    email = "letsencrypt@hwlium.com";
    group = "postgres";
    webroot = "/var/www/alpha.database.hwlium.com";
    reloadServices = ["postgresql.service"];
  };

  services.nginx = {
    enable = true;

    virtualHosts."alpha.database.hwlium.com" = {
      root = "/var/www/alpha.database.hwlium.com";
    };
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_13;

    enableTCPIP = true;
    authentication = ''
      # Local
      local all all trust
      host all all 127.0.0.1/32 trust

      # Remote
      host all all all scram-sha-256
    '';

    settings = {
      password_encryption = "scram-sha-256";
      ssl = true;
      ssl_cert_file = "/run/credentials/postgresql.service/cert.pem";
      ssl_key_file = "/run/credentials/postgresql.service/key.pem";
    };

    ensureDatabases = ["hrel" "vault"];

    ensureUsers = [
      {
        name = "hrel";
        ensurePermissions = {
          "DATABASE hrel" = "ALL PRIVILEGES";
        };
      }
      {
        name = "vault";
        ensurePermissions = {
          "DATABASE vault" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  systemd.services.postgresql = {
    requires = ["acme-alpha.database.hwlium.com.service"];
    after = ["acme-alpha.database.hwlium.com.service"];

    serviceConfig.LoadCredential = [
      "cert.pem:/var/lib/acme/alpha.database.hwlium.com/cert.pem"
      "key.pem:/var/lib/acme/alpha.database.hwlium.com/key.pem"
    ];
  };

  networking.firewall.allowedTCPPorts = [80 5432];
}
