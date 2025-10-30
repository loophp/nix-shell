{ inputs, ... }:
{
  perSystem =
    {
      system,
      ...
    }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [
          (final: prev: {
            nix-phps = inputs.nix-phps.overlays.default final prev;
          })
        ];
        config.allowUnfree = true;
      };
    };
}
