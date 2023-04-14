{
  config,
  specialArgs,
  ...
}: {
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    registry.nixpkgs.flake = specialArgs.inputs.nixpkgs;

    gc.automatic = true;
    distributedBuilds = true;

    buildMachines = [
      {
        hostName = "eu.nixbuild.net";
        system = "x86_64-linux";
        maxJobs = 100;
        supportedFeatures = ["benchmark" "big-parallel"];
      }
      {
        hostName = "eu.nixbuild.net";
        system = "i686-linux";
        maxJobs = 100;
        supportedFeatures = ["benchmark" "big-parallel"];
      }
      {
        hostName = "eu.nixbuild.net";
        system = "armv7l-linux";
        maxJobs = 100;
        supportedFeatures = ["benchmark" "big-parallel"];
      }
      {
        hostName = "eu.nixbuild.net";
        system = "aarch64-linux";
        maxJobs = 100;
        supportedFeatures = ["benchmark" "big-parallel"];
      }
    ];
  };
}
