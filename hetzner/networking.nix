{ config, lib, ... }: {
  networking = {
    domain = "servers.hwlium.com";

    useDHCP = true;

    defaultGateway6 = {
      address = "fe80::1";
      interface = "enp98s0f0";
    };
  };
}
