{ config, lib, ... }: {
  networking = {
    useDHCP = lib.mkDefault true;
    nameservers = [ "1.1.1.1" "8.8.8.8" ];

    defaultGateway6 = {
      address = "fe80::1";
      interface = "enp4s0";
    };
  };
}
