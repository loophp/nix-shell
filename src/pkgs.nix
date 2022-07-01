nixpkgs:
nix-phps:
system:

let
  pkgs = import nixpkgs {
    inherit system;
    overlays = [ nix-phps.overlays.default ];
    # This is only needed for the PHP oci8 extension.
    config = { allowUnfree = true; };
  };
in
  pkgs