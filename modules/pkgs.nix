{ inputs, ... }:
{
  flake-file.inputs = {
    nix-phps.url = "github:fossar/nix-phps";
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
  };

  perSystem =
    {
      system,
      ...
    }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;

        overlays = [
          (final: prev: {
            nix-phps = inputs.nix-phps.overlays.default final prev;
          })
        ];
      };
    };
}
