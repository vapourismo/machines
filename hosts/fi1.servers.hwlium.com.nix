{config, ...}: {
  imports = [
    ../hetzner/dual-disk-setup.nix
    ../hetzner/networking.nix
    ../common
    ../components/serve-nix-store.nix
    ../components/postgresql-database.nix
    ../components/vault.nix
    ../components/tezos.nix
    ../components/hydra.nix
    ../components/ole.lol.nix
  ];

  networking = {
    hostName = "fi1";
    hostId = "9cd372da";

    interfaces = {
      enp98s0f0.ipv6.addresses = [
        {
          address = "2a01:4f9:4a:24ed::";
          prefixLength = 64;
        }
      ];
    };
  };
}
