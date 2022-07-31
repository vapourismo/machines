{ config, lib, specialArgs, ... }: {
  imports = [
    ./networking.nix
    ./ssh.nix
    ./nix.nix
    ./virtualisation.nix
    ./fail2ban.nix
  ];

  system = {
    stateVersion = "22.11";

    configurationRevision = lib.mkIf (specialArgs.inputs.self ? rev) specialArgs.inputs.self.rev;
  };
}
