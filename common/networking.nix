{
  config,
  lib,
  ...
}: {
  networking = {
    useDHCP = lib.mkDefault true;
    nameservers = ["1.1.1.1" "8.8.8.8"];

    firewall.allowedTCPPorts = [
      8776
    ];
  };
}
