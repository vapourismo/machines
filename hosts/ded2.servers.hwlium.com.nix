{ config, ... }: {
  imports = [
    ../hetzner/dual-disk-setup.nix
    ../hetzner/networking.nix
    ../common
  ];

  networking = {
    hostName = "ded2";
    hostId = "fd1d7a89";

    interfaces = {
      enp4s0.ipv6.addresses = [
        {
          address = "2a01:4f8:171:3849::";
          prefixLength = 64;
        }
      ];

      vs1.ipv4.addresses = [
        {
          address = "10.0.0.2";
          prefixLength = 24;
        }
      ];
    };
  };
}
