{
  description = "NixOS Machines";

  inputs = {
    # flake-utils.url = github:numtide/flake-utils;
    nixpkgs.url = github:NixOS/nixpkgs;
  };

  outputs = { self, nixpkgs }: {
    nixosModules = {
      common-hardware = { config, lib, modulesPath, ... }: {
        imports = [
          (modulesPath + "/installer/scan/not-detected.nix")
        ];

        boot.initrd.availableKernelModules = [ "ahci" "sd_mod" ];
        boot.initrd.kernelModules = [ ];
        boot.kernelModules = [ "kvm-intel" ];
        boot.extraModulePackages = [ ];

        boot.loader.grub.enable = true;
        boot.loader.grub.version = 2;
        boot.loader.grub.device = "/dev/sda";

        fileSystems."/" = {
          device = "/dev/disk/by-label/nixos";
          fsType = "ext4";
        };

        swapDevices = [
          { device = "/dev/disk/by-label/swap"; }
        ];

        networking.useDHCP = lib.mkDefault true;

        powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
        hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      };

      common-ssh = { config, ... }: {
        services.sshd.enable = true;
        programs.mosh.enable = true;

        users.users.root.openssh.authorizedKeys.keys = [
          # iKek Pro
          "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEwKv2ut/a9nCD2EZ0wB4y4Bq4Jzd1I55+sXcZ/yr5X7P2KP0ZzmoVrvcaAhJhVzzI6HCjknQhzNnJR3SiX4G9s="
          # 1.workspace
          "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBHTvJT1i/dhcuxJ96JMQVXPRievxWrb8rmPSO8tlsbbhD/PzXTm2kJkw6PKGrkeF+tpG0TM8m3stIrczUcch/58="
        ];
      };

      common-firewall = { config, ... }: {
        networking.firewall.allowedTCPPorts = [ 22 80 443 ];
      };

      common = { config, lib, ... }: {
        imports = with self.nixosModules; [
          common-hardware
          common-firewall
          common-ssh
        ];

        system.configurationRevision = lib.mkIf (self ? rev) self.rev;
      };
    };

    nixosConfigurations = {
      ded1 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = with self.nixosModules; [
          common
        ];
      };

      ded2 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = with self.nixosModules; [
          common
        ];
      };
    };
  };
}
