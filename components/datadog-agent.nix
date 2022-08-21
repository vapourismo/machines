{ config, ... }: {
  services.datadog-agent = {
    enable = true;

    site = "datadoghq.eu";
    apiKeyFile = "/run/keys/datadog-api-key";

    enableLiveProcessCollection = true;

    extraConfig = {
      "logs_enabled" = true;
    };

    checks.nginx = {
      init_config = null;

      instances = [
        {
          "nginx_status_url" = "http://localhost:81/nginx_status/";
        }
      ];

      logs = [
        {
          type = "file";
          path = "/var/log/nginx/access.log";
          service = "nginx";
          source = "nginx";
        }
        {
          type = "file";
          path = "/var/log/nginx/error.log";
          service = "nginx";
          source = "nginx";
        }
      ];
    };
  };

  users.users.datadog.extraGroups = [ "keys" "nginx" ];

  services.nginx.virtualHosts."datadog" = {
    listen = [
      {
        addr = "127.0.0.1";
        port = 81;
      }
    ];

    serverName = "localhost";

    extraConfig = ''
      access_log off;
      allow 127.0.0.1;
      deny all;
    '';

    locations."/nginx_status".extraConfig = ''
      stub_status;
      server_tokens on;
    '';
  };
}
