{
  description = "NixOS Machines";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, flake-utils }: {
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

        powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
        hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      };

      common-network = { config, lib, ... }: {
        networking = {
          domain = "servers.hwlium.com";

          useDHCP = lib.mkDefault true;
          nameservers = [ "1.1.1.1" "8.8.8.8" ];

          firewall.allowedTCPPorts = [ 22 80 443 ];

          defaultGateway6 = {
            address = "fe80::1";
            interface = "enp4s0";
          };

          vlans = {
            vs1 = {
              id = 4000;
              interface = "enp4s0";
            };
          };
        };
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

      common-nix = { config, ... }: {
        nix = {
          extraOptions = ''
            experimental-features = nix-command flakes
          '';

          registry.nixpkgs.flake = nixpkgs;

          gc.automatic = true;
        };
      };

      common = { config, lib, ... }: {
        imports = with self.nixosModules; [
          common-hardware
          common-network
          common-ssh
          common-nix
        ];

        system = {
          stateVersion = "22.11";

          configurationRevision = lib.mkIf (self ? rev) self.rev;
        };
      };

      acme = { config, ... }: {
        security.acme = {
          acceptTerms = true;
          defaults.email = "letsencrypt@hwlium.com";
        };
      };

      serve-nix-store = { config, ... }: {
        nix = {
          sshServe = {
            enable = true;
            write = true;

            keys = [
              # Nix Cache Use (hrel)
              "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBDCaUKnuSXxgS50BdWZgrtsmeJ/s5vD65lQTagAp8OUrc4uI4S+H7aGMP79TQdKwm9unNxGWS0WudceOyYzUyno="
              # Desktop
              "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKKRTgvRNbWuT85F9/qKZy9cJ47bC7kZhEgDz/dC24F+WQC7sV+MrimPb7cuyRyL7YAgf5kebM97eUa1rMNYfX+avD17pCW/3bVu37VPN+s3UHECSFN0BNTT0D0sIWXHcJdZkoa2UUEMCPzzjBpOQLNtoUQhdkrwJIS7KMjw9DJWf6gCGzUEYW2mzhnIzL5OeBHD4IGLKaIzAANKxALDIugfUhB3WlMUidhlu1TyaXvqsJ7Vj2OfX2Dv75wZIjeBRZse4Yq9fMWjiUcZds88eBX6y7ts7zzv0jd1pbThc7PIQLOsHAOapOFElS6gZlLOf+9k9f9j3LPFi8xu07OZCP"
            ];
          };

          settings.trusted-users = [ "nix-ssh" ];
        };
      };

      postgresql-database = { config, pkgs, ... }: {
        security.acme.certs."alpha.database.hwlium.com" = {
          group = "postgres";
          webroot = "/var/www/alpha.database.hwlium.com";
          postRun = ''
            chown postgres:postgres /var/lib/acme/alpha.database.hwlium.com/*.pem
            systemctl restart postgresql.service
          '';
        };

        services.nginx = {
          enable = true;

          virtualHosts."alpha.database.hwlium.com" = {
            root = "/var/www/alpha.database.hwlium.com";
          };
        };

        services.postgresql = {
          enable = true;
          package = pkgs.postgresql_13;

          enableTCPIP = true;
          authentication = ''
            # Local
            local all all trust
            host all all 127.0.0.1/32 trust

            # Remote
            host all all all scram-sha-256
          '';

          settings = {
            password_encryption = "scram-sha-256";
            ssl = true;
            ssl_cert_file = "/var/lib/acme/alpha.database.hwlium.com/cert.pem";
            ssl_key_file = "/var/lib/acme/alpha.database.hwlium.com/key.pem";
          };

          ensureDatabases = [ "hrel" ];

          ensureUsers = [
            {
              name = "hrel";
              ensurePermissions = {
                "DATABASE hrel" = "ALL PRIVILEGES";
              };
            }
          ];
        };

        networking.firewall.allowedTCPPorts = [ 5432 ];
      };

      host-ded1 = { config, ... }: {
        imports = with self.nixosModules; [
          common
          serve-nix-store
          acme
          postgresql-database
        ];

        networking = {
          hostName = "ded1";
          hostId = "dfc13c64";

          interfaces = {
            enp4s0.ipv6.addresses = [
              {
                address = "2a01:4f8:162:3248::";
                prefixLength = 64;
              }
            ];

            vs1.ipv4.addresses = [
              {
                address = "10.0.0.1";
                prefixLength = 24;
              }
            ];
          };
        };
      };

      host-ded2 = { config, ... }: {
        imports = with self.nixosModules; [
          common
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
      };
    };

    nixosConfigurations = {
      ded1 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [ self.nixosModules.host-ded1 ];
      };

      ded2 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [ self.nixosModules.host-ded2 ];
      };
    };

    colmena = {
      meta = {
        nixpkgs = nixpkgs.legacyPackages."x86_64-linux";

        name = "Available Servers";
      };

      ded1 = _: {
        deployment = {
          targetHost = "ded1.servers.hwlium.com";
          tags = [ "ded" ];
          buildOnTarget = true;
        };

        imports = [ self.nixosModules.host-ded1 ];
      };

      ded2 = _: {
        deployment = {
          targetHost = "ded2.servers.hwlium.com";
          tags = [ "ded" ];
          buildOnTarget = true;
        };

        imports = [ self.nixosModules.host-ded2 ];
      };
    };
  } // flake-utils.lib.eachDefaultSystem (system: {
    devShell = nixpkgs.legacyPackages.${system}.mkShell {
      buildInputs = with nixpkgs.legacyPackages.${system}; [
        colmena
        nixpkgs-fmt
      ];
    };
  });
}
