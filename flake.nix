{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-phps.url = "github:fossar/nix-phps";
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    import-tree.url = "github:vic/import-tree";
    # Shim to make flake.nix work with stable Nix.
    flake-compat.url = "github:nix-community/flake-compat";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    make-shell.url = "github:nicknovitski/make-shell";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
