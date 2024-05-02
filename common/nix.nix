{specialArgs, ...}: {
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    registry.nixpkgs.flake = specialArgs.inputs.nixpkgs;

    optimise.automatic = true;
    gc.automatic = true;
  };
}
