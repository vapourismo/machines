{
  pkgs,
  specialArgs,
  ...
}: let
  package = import specialArgs.inputs.tezos;
in {
  systemd.services = {
    tezos-node = {
      enable = true;
      wantedBy = ["multi-user.target"];
      script = ''
        ${package}/bin/octez-node run --rpc-addr 127.0.0.1:8732 --history-mode rolling
      '';
    };
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."tezos.hwlium.com" = {
      enableACME = true;
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:8732/";
        extraConfig = ''
          proxy_ssl_server_name on;
        '';
      };
    };
  };
}
