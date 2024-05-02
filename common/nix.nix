{specialArgs, ...}: {
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      min-free = ${toString (1024 * 1024 * 1024)}
      max-free = ${toString (10 * 1024 * 1024 * 1024)}
    '';

    registry.nixpkgs.flake = specialArgs.inputs.nixpkgs;

    optimise.automatic = true;
  };
}
