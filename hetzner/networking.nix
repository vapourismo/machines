{ config, lib, ... }: {
  networking = {
    domain = "servers.hwlium.com";

    vlans.vs1 = {
      id = 4000;
      interface = "enp4s0";
    };
  };
}
