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
        boot.loader.grub.devices = [ "/dev/sda" "/dev/sdb" ];

        fileSystems."/" = {
          device = "/dev/disk/by-label/nixos";
          fsType = "ext4";
        };

        swapDevices = [
          { device = "/dev/disk/by-label/swap"; }
        ];

        networking = {
          useDHCP = lib.mkDefault true;

          defaultGateway6 = {
            address = "fe80::1";
            interface = "enp4s0";
          };
        };

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
          # Desktop
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKKRTgvRNbWuT85F9/qKZy9cJ47bC7kZhEgDz/dC24F+WQC7sV+MrimPb7cuyRyL7YAgf5kebM97eUa1rMNYfX+avD17pCW/3bVu37VPN+s3UHECSFN0BNTT0D0sIWXHcJdZkoa2UUEMCPzzjBpOQLNtoUQhdkrwJIS7KMjw9DJWf6gCGzUEYW2mzhnIzL5OeBHD4IGLKaIzAANKxALDIugfUhB3WlMUidhlu1TyaXvqsJ7Vj2OfX2Dv75wZIjeBRZse4Yq9fMWjiUcZds88eBX6y7ts7zzv0jd1pbThc7PIQLOsHAOapOFElS6gZlLOf+9k9f9j3LPFi8xu07OZCP"
        ];
      };

      common-firewall = { config, ... }: {
        networking.firewall.allowedTCPPorts = [ 22 80 443 ];
      };

      common-nix = { config, ... }: {
        nix = {
          extraOptions = ''
            experimental-features = nix-command flakes
          '';

          registry.nixpkgs.flake = nixpkgs;

          sshServe = {
            enable = true;
            write = true;

            keys = [
              # Desktop
              "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKKRTgvRNbWuT85F9/qKZy9cJ47bC7kZhEgDz/dC24F+WQC7sV+MrimPb7cuyRyL7YAgf5kebM97eUa1rMNYfX+avD17pCW/3bVu37VPN+s3UHECSFN0BNTT0D0sIWXHcJdZkoa2UUEMCPzzjBpOQLNtoUQhdkrwJIS7KMjw9DJWf6gCGzUEYW2mzhnIzL5OeBHD4IGLKaIzAANKxALDIugfUhB3WlMUidhlu1TyaXvqsJ7Vj2OfX2Dv75wZIjeBRZse4Yq9fMWjiUcZds88eBX6y7ts7zzv0jd1pbThc7PIQLOsHAOapOFElS6gZlLOf+9k9f9j3LPFi8xu07OZCP"
            ];
          };

          settings.trusted-users = [ "nix-ssh" ];

          gc.automatic = true;
        };
      };

      common = { config, lib, ... }: {
        imports = with self.nixosModules; [
          common-hardware
          common-firewall
          common-ssh
          common-nix
        ];

        system.configurationRevision = lib.mkIf (self ? rev) self.rev;
      };
    };

    nixosConfigurations = {
      ded1 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = with self.nixosModules; [
          common
          ({ config, ... }: {
            networking.interfaces.enp4s0.ipv6.addresses = [
              {
                address = "2a01:4f8:162:3248::";
                prefixLength = 64;
              }
            ];
          })
        ];
      };

      ded2 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = with self.nixosModules; [
          common
          ({ config, ... }: {
            networking.interfaces.enp4s0.ipv6.addresses = [
              {
                address = "2a01:4f8:171:3849::";
                prefixLength = 64;
              }
            ];
          })
        ];
      };
    };
  };
}
