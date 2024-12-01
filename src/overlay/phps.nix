inputs:

final: prev:

let
  buildPhpFromComposer = (inputs.self.overlays.default final prev).api.buildPhpFromComposer;
  nix-phps = inputs.nix-phps.overlays.default final prev;
in
builtins.mapAttrs (
  name: value:
  buildPhpFromComposer {
    php = value;
    src = inputs.self;
  }
) nix-phps
