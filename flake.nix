{
  description = "NixOS Machines";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, flake-utils }@inputs:
    {
      nixosConfigurations =
        # Import NixOS configurations from Colmena configurations.
        nixpkgs.lib.mapAttrs
          (name: mkConfig: nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              (args: builtins.removeAttrs (mkConfig args) [ "deployment" ])
            ];
            specialArgs = { inherit inputs; };
          })
          (nixpkgs.lib.filterAttrs (_: nixpkgs.lib.isFunction) self.colmena);

      colmena = {
        meta = {
          name = "Available Servers";
          nixpkgs = nixpkgs.legacyPackages."x86_64-linux";
          specialArgs = { inherit inputs; };
        };

        "fi1.servers.hwlium.com" = _: {
          deployment = {
            targetHost = "fi1.servers.hwlium.com";
            tags = [ "ded" ];
            buildOnTarget = true;
          };

          imports = [ ./hosts/fi1.servers.hwlium.com.nix ];
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
