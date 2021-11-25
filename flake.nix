{
  description = "PHP/Composer/SymfonyCLi/GithubCLi/git/sqlite/make/docker-compose";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    flake-utils.url = "github:numtide/flake-utils";
    phps.url = "github:fossar/nix-phps";
  };

  outputs = { self, flake-utils, nixpkgs, phps }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
        };
      in {
        devShells = {
          default = import ./resources/dev/common.nix {
            pkgs = pkgs;
            phps = phps.packages.${system};
            version = "php80";
            phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x []) (default all);
          };

          php56 = import ./resources/dev/common.nix {
            pkgs = pkgs;
            phps = phps.packages.${system};
            version = "php56";
            phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x []) (default all);
          };

          php70 = import ./resources/dev/common.nix {
            pkgs = pkgs;
            phps = phps.packages.${system};
            version = "php70";
            phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x []) (default all);
          };

          php71 = import ./resources/dev/common.nix {
            pkgs = pkgs;
            phps = phps.packages.${system};
            version = "php71";
            phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x []) (default all);
          };

          php72 = import ./resources/dev/common.nix {
            pkgs = pkgs;
            phps = phps.packages.${system};
            version = "php72";
            phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x []) (default all);
          };

          php73 = import ./resources/dev/common.nix {
            pkgs = pkgs;
            phps = phps.packages.${system};
            version = "php73";
            phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x []) (default all);
          };

          php74 = import ./resources/dev/common.nix {
            pkgs = pkgs;
            phps = phps.packages.${system};
            version = "php74";
            phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x []) (default all);
          };

          php74-nodebug = import ./resources/dev/common.nix {
            pkgs = pkgs;
            phps = phps.packages.${system};
            version = "php74";
            phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x [all.xdebug all.pcov]) (default all);
          };

          php80 = import ./resources/dev/common.nix {
            pkgs = pkgs;
            phps = phps.packages.${system};
            version = "php80";
            phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x []) (default all);
          };

          php80-nodebug = import ./resources/dev/common.nix {
            pkgs = pkgs;
            phps = phps.packages.${system};
            version = "php80";
            phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x [all.xdebug all.pcov]) (default all);
          };
        };
      }
    );
}
