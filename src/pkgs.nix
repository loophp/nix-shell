nixpkgs:
nix-phps:
system:

let
  pkgs = import nixpkgs {
    inherit system;
    overlays = [ nix-phps.overlays.default ];
  };
in
  pkgs