{ config, ... }: {
  nix = {
    sshServe = {
      enable = true;
      write = true;

      keys = [
        # Nix Cache Use (hrel)
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBDCaUKnuSXxgS50BdWZgrtsmeJ/s5vD65lQTagAp8OUrc4uI4S+H7aGMP79TQdKwm9unNxGWS0WudceOyYzUyno="
        # Nix Cache Use (opam-nix-integration)
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM2qRDuB5cZurKKtPjVq+BvMIloH7IYK71E27F4HgfuM"
        # Desktop
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKKRTgvRNbWuT85F9/qKZy9cJ47bC7kZhEgDz/dC24F+WQC7sV+MrimPb7cuyRyL7YAgf5kebM97eUa1rMNYfX+avD17pCW/3bVu37VPN+s3UHECSFN0BNTT0D0sIWXHcJdZkoa2UUEMCPzzjBpOQLNtoUQhdkrwJIS7KMjw9DJWf6gCGzUEYW2mzhnIzL5OeBHD4IGLKaIzAANKxALDIugfUhB3WlMUidhlu1TyaXvqsJ7Vj2OfX2Dv75wZIjeBRZse4Yq9fMWjiUcZds88eBX6y7ts7zzv0jd1pbThc7PIQLOsHAOapOFElS6gZlLOf+9k9f9j3LPFi8xu07OZCP"
      ];
    };

    settings.trusted-users = [ "nix-ssh" ];
  };

  services.nix-serve = {
    enable = true;
    secretKeyFile = "/run/keys/nix-store.sec";
    bindAddress = "127.0.0.1";
    port = 8580;
  };

  services.nginx = {
    enable = true;

    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."nix.cache.hwlium.com" = {
      enableACME = true;
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:${builtins.toString config.services.nix-serve.port}/";
        extraConfig = ''
          proxy_ssl_server_name on;
        '';
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 443 ];
}
