{
  config,
  lib,
  specialArgs,
  ...
}: {
  imports = [
    ./networking.nix
    ./ssh.nix
    ./nix.nix
    ./fail2ban.nix
    ./acme.nix
  ];

  system = {
    stateVersion = "22.11";

    configurationRevision = lib.mkIf (specialArgs.inputs.self ? rev) specialArgs.inputs.self.rev;
  };
}
