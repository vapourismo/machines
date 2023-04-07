{
  pkgs,
  specialArgs,
  ...
}: let
  package = (import specialArgs.inputs.tezos).overrideAttrs (old: {
    buildInputs = (old.buildInputs or []) ++ [pkgs.makeWrapper];

    postFixup = ''
      ${old.postFixup or ""}
      for file in $(find $out/bin -type f); do
        wrapProgram $file --set OPAM_SWITCH_PREFIX ${old.OPAM_SWITCH_PREFIX}
      done
    '';
  });
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
