{
  description = "NixOS Machines";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, flake-utils }@inputs:
    {
      nixosConfigurations =
        let
          fromColmena = name: args:
            builtins.removeAttrs (self.colmena.${name} args) [ "deployment" ];
        in
        {
          "fi1.servers.hwlium.com" = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [ (fromColmena "fi1.servers.hwlium.com") ];
            specialArgs = { inherit inputs; };
          };
        };

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
