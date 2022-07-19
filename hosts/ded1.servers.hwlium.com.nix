{ config, ... }: {
  imports = [
    ../hetzner/dual-disk-setup.nix
    ../hetzner/networking.nix
    ../common
    ../components/serve-nix-store.nix
    ../components/postgresql-database.nix
  ];

  networking = {
    hostName = "ded1";
    hostId = "dfc13c64";

    interfaces = {
      enp4s0.ipv6.addresses = [
        {
          address = "2a01:4f8:162:3248::";
          prefixLength = 64;
        }
      ];

      vs1.ipv4.addresses = [
        {
          address = "10.0.0.1";
          prefixLength = 24;
        }
      ];
    };
  };
}
