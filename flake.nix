# DO-NOT-EDIT. This file was auto-generated using github:denful/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);

  inputs = {
    flake-compat = {
      url = "github:NixOS/flake-compat";
      flake = false;
    };
    flake-file = {
      url = "github:denful/flake-file";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    import-tree = {
      url = "github:denful/import-tree";
    };
    json-sort = {
      url = "github:drupol/json-sort";
      inputs = {
        flake-compat.follows = "flake-compat";
        flake-file.follows = "flake-file";
        flake-parts.follows = "flake-parts";
        import-tree.follows = "import-tree";
        make-shell.follows = "make-shell";
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    make-shell = {
      url = "github:nicknovitski/make-shell";
      inputs.flake-compat.follows = "flake-compat";
    };
    nix-phps = {
      url = "github:fossar/nix-phps";
      inputs = {
        flake-compat.follows = "flake-compat";
        nixpkgs.follows = "nixpkgs";
      };
    };
    nixpkgs = {
      url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
    };
    pedantix = {
      url = "github:swarsel/pedantix";
      inputs = {
        flake-parts.follows = "flake-parts";
        git-hooks-nix.inputs.flake-compat.follows = "flake-compat";
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
