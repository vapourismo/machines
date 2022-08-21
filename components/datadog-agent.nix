{ config, ... }: {
  services.datadog-agent = {
    enable = true;
    site = "datadoghq.eu";
    apiKeyFile = "/run/keys/datadog-api-key";
    enableLiveProcessCollection = true;
  };

  users.users.datadog.extraGroups = [ "keys" ];
}
