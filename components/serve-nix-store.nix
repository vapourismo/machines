{ config, ... }: {
  nix = {
    sshServe = {
      enable = true;
      write = true;

      keys = [
        # Nix Cache Use (hrel)
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBDCaUKnuSXxgS50BdWZgrtsmeJ/s5vD65lQTagAp8OUrc4uI4S+H7aGMP79TQdKwm9unNxGWS0WudceOyYzUyno="
        # Desktop
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKKRTgvRNbWuT85F9/qKZy9cJ47bC7kZhEgDz/dC24F+WQC7sV+MrimPb7cuyRyL7YAgf5kebM97eUa1rMNYfX+avD17pCW/3bVu37VPN+s3UHECSFN0BNTT0D0sIWXHcJdZkoa2UUEMCPzzjBpOQLNtoUQhdkrwJIS7KMjw9DJWf6gCGzUEYW2mzhnIzL5OeBHD4IGLKaIzAANKxALDIugfUhB3WlMUidhlu1TyaXvqsJ7Vj2OfX2Dv75wZIjeBRZse4Yq9fMWjiUcZds88eBX6y7ts7zzv0jd1pbThc7PIQLOsHAOapOFElS6gZlLOf+9k9f9j3LPFi8xu07OZCP"
      ];
    };

    settings.trusted-users = [ "nix-ssh" ];
  };
}
