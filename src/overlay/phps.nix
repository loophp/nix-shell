inputs:

final:
prev:

let
  buildPhpFromComposer = (inputs.self.overlays.default final prev).api.buildPhpFromComposer;
  nix-phps = inputs.nix-phps.overlays.default final prev;
  php-src-nix-snapshot = inputs.php-src-nix.overlays.snapshot final prev;
in
builtins.mapAttrs
  (name: value: buildPhpFromComposer { php = value; src = inputs.self; })
  php-src-nix-snapshot // nix-phps
