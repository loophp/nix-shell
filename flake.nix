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
            inherit pkgs;
            phps = phps.packages.${system};
            version = "php80";
            phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x []) (default all);
            apxs2Support = true;
          };

          default-nts = import ./resources/dev/common.nix {
            inherit pkgs;
            phps = phps.packages.${system};
            version = "php80";
            phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x []) (default all);
            apxs2Support = false;
          };

          php56 = import ./resources/dev/common.nix {
            inherit pkgs;
            phps = phps.packages.${system};
            version = "php56";
            phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x []) (default all);
            apxs2Support = true;
          };

          php56-nts = import ./resources/dev/common.nix {
            inherit pkgs;
            phps = phps.packages.${system};
            version = "php56";
            phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x []) (default all);
            apxs2Support = false;
          };

          php70 = import ./resources/dev/common.nix {
            inherit pkgs;
            phps = phps.packages.${system};
            version = "php70";
            phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x []) (default all);
            apxs2Support = true;
          };

          php70-nts = import ./resources/dev/common.nix {
            inherit pkgs;
            phps = phps.packages.${system};
            version = "php70";
            phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x []) (default all);
            apxs2Support = false;
          };

          php71 = import ./resources/dev/common.nix {
            inherit pkgs;
            phps = phps.packages.${system};
            version = "php71";
            phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x []) (default all);
            apxs2Support = true;
          };

          php71-nts = import ./resources/dev/common.nix {
            inherit pkgs;
            phps = phps.packages.${system};
            version = "php71";
            phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x []) (default all);
            apxs2Support = false;
          };

          php72 = import ./resources/dev/common.nix {
            inherit pkgs;
            phps = phps.packages.${system};
            version = "php72";
            phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x []) (default all);
            apxs2Support = true;
          };

          php72-nts = import ./resources/dev/common.nix {
            inherit pkgs;
            phps = phps.packages.${system};
            version = "php72";
            phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x []) (default all);
            apxs2Support = false;
          };

          php73 = import ./resources/dev/common.nix {
            inherit pkgs;
            phps = phps.packages.${system};
            version = "php73";
            phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x []) (default all);
            apxs2Support = true;
          };

          php73-nts = import ./resources/dev/common.nix {
            inherit pkgs;
            phps = phps.packages.${system};
            version = "php73";
            phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x []) (default all);
            apxs2Support = false;
          };

          php74 = import ./resources/dev/common.nix {
            inherit pkgs;
            phps = phps.packages.${system};
            version = "php74";
            phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x []) (default all);
            apxs2Support = true;
          };

          php74-nts = import ./resources/dev/common.nix {
            inherit pkgs;
            phps = phps.packages.${system};
            version = "php74";
            phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x []) (default all);
            apxs2Support = false;
          };

          php74-nodebug = import ./resources/dev/common.nix {
            inherit pkgs;
            phps = phps.packages.${system};
            version = "php74";
            phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x [all.xdebug all.pcov]) (default all);
            apxs2Support = true;
          };

          php74-nts-nodebug = import ./resources/dev/common.nix {
            inherit pkgs;
            phps = phps.packages.${system};
            version = "php74";
            phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x [all.xdebug all.pcov]) (default all);
            apxs2Support = false;
          };

          php80 = import ./resources/dev/common.nix {
            inherit pkgs;
            phps = phps.packages.${system};
            version = "php80";
            phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x []) (default all);
            apxs2Support = true;
          };

          php80-nts = import ./resources/dev/common.nix {
            inherit pkgs;
            phps = phps.packages.${system};
            version = "php80";
            phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x []) (default all);
            apxs2Support = false;
          };

          php80-nodebug = import ./resources/dev/common.nix {
            inherit pkgs;
            phps = phps.packages.${system};
            version = "php80";
            phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x [all.xdebug all.pcov]) (default all);
            apxs2Support = true;
          };

          php80-nts-nodebug = import ./resources/dev/common.nix {
            inherit pkgs;
            phps = phps.packages.${system};
            version = "php80";
            phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x [all.xdebug all.pcov]) (default all);
            apxs2Support = false;
          };

          php81 = import ./resources/dev/common.nix {
            inherit pkgs;
            phps = phps.packages.${system};
            version = "php81";
            phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x []) (default all);
            apxs2Support = true;
          };

          php81-nts = import ./resources/dev/common.nix {
            inherit pkgs;
            phps = phps.packages.${system};
            version = "php81";
            phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x []) (default all);
            apxs2Support = false;
          };

          php81-nodebug = import ./resources/dev/common.nix {
            inherit pkgs;
            phps = phps.packages.${system};
            version = "php81";
            phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x [all.xdebug all.pcov]) (default all);
            apxs2Support = true;
          };

          php81-nts-nodebug = import ./resources/dev/common.nix {
            inherit pkgs;
            phps = phps.packages.${system};
            version = "php81";
            phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x [all.xdebug all.pcov]) (default all);
            apxs2Support = false;
          };
        };
      }
    );
}
