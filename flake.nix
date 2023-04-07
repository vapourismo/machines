{
  description = "NixOS Machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    tezos = {
      url = "gitlab:tezos/tezos/f9471bdacdad1dfeeffe81d21f91d3b7ee268fa4";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs:
    {
      nixosConfigurations =
        # Import NixOS configurations from Colmena configurations.
        nixpkgs.lib.mapAttrs
        (name: mkConfig:
          nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              (args: builtins.removeAttrs (mkConfig args) ["deployment"])
            ];
            specialArgs = {inherit inputs;};
          })
        (nixpkgs.lib.filterAttrs (_: nixpkgs.lib.isFunction) self.colmena);

      colmena = {
        meta = {
          name = "Available Servers";
          nixpkgs = nixpkgs.legacyPackages."x86_64-linux";
          specialArgs = {inherit inputs;};
        };

        "fi1.servers.hwlium.com" = _: {
          deployment = {
            targetHost = "fi1.servers.hwlium.com";
            tags = ["servers.hwlium.com"];
            buildOnTarget = true;

            keys = {
              "nix-store.sec" = {
                keyCommand = ["cat" "./secrets/nix-store.sec"];
              };

              "vault-storage.hcl" = {
                keyCommand = ["cat" "./secrets/vault-storage.hcl"];
                user = "vault";
              };

              "kibana-basic" = {
                keyCommand = ["cat" "./secrets/kibana-basic"];
                permissions = "0644";
              };
            };
          };

          imports = [./hosts/fi1.servers.hwlium.com.nix];
        };
      };
    }
    // flake-utils.lib.eachDefaultSystem (system: {
      packages.tezos = (import inputs.tezos).overrideAttrs (old: {
        buildInputs =
          (old.buildInputs or [])
          ++ [
            nixpkgs.legacyPackages.${system}.makeWrapper
          ];

        postFixup = ''
          ${old.postFixup or ""}
          for file in $(find $out/bin -type f); do
            wrapProgram $file --set OPAM_SWITCH_PREFIX ${old.OPAM_SWITCH_PREFIX}
          done
        '';
      });

      devShell = nixpkgs.legacyPackages.${system}.mkShell {
        buildInputs = with nixpkgs.legacyPackages.${system}; [
          colmena
          alejandra
          nixos-rebuild
        ];
      };
    });
}
