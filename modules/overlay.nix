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
        overlays = [ inputs.self.overlays.default ];
        config.allowUnfree = true;
      };
    };

  flake = {
    overlays.default =
      final: prev:
      let
        buildPhpFromComposer = prev.callPackage ../src/build-support/build-php-from-composer.nix { };
        nix-phps = inputs.nix-phps.overlays.default final prev;
        phps = builtins.mapAttrs (
          _name: value:
          buildPhpFromComposer {
            php = value;
            src = inputs.self;
          }
        ) nix-phps;
        api = {
          inherit buildPhpFromComposer;
        };
      in
      phps // api;
  };

}
