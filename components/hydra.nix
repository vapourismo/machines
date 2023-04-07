{
  config,
  pkgs,
  ...
}: {
  services.hydra = {
    enable = true;
    listenHost = "localhost";
    hydraURL = "https://hydra.hwlium.com";
    notificationSender = "hydra@hwlium.com";
    package = pkgs.hydra_unstable.overrideAttrs (old: {
      patches = (old.patches or []) ++ [./unrestrict-hydra.patch];
      doCheck = false;
    });
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."hydra.hwlium.com" = {
      enableACME = true;
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:${builtins.toString config.services.hydra.port}/";
        extraConfig = ''
          proxy_ssl_server_name on;
        '';
      };
    };
  };
}
