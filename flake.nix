{
  description = "PHP/Composer/SymfonyCLi/GithubCLi/git/sqlite/make";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-phps.url = "github:fossar/nix-phps";
    php-src-nix.url = "github:loophp/php-src-nix";
    # Shim to make flake.nix work with stable Nix.
    flake-compat.url = "github:nix-community/flake-compat";
    systems.url = "github:nix-systems/default";
  };

  outputs = inputs @ { self, flake-parts, systems, ... }: flake-parts.lib.mkFlake { inherit inputs; } {
    systems = import systems;

    flake = {
      templates = {
        basic = {
          path = ./templates/basic;
          description = "A basic template for getting started with PHP development";
          welcomeText = builtins.readFile ./templates/basic/README.md;
        };
      };

      overlays.default = import ./src/overlay inputs;
    };

    perSystem = { self', inputs', config, pkgs, system, lib, ... }:
      let
        buildPhpFromComposer = pkgs.callPackage ./src/build-support/build-php-from-composer.nix { };

        phps = lib.mapAttrs
          # To fix: Why using this while it is already in use in the overlay?
          (name: value: buildPhpFromComposer { php = value; src = self; })
          (lib.filterAttrs (k: v: lib.isDerivation v) (inputs.self.overlays.default null pkgs));

        envPackages = [
          pkgs.symfony-cli
          pkgs.sqlite
        ];

        packages = lib.foldlAttrs
          (
            carry: name: php:
              carry // {
                "${name}" = php;
                "env-${name}" = pkgs.buildEnv { name = "env-${name}"; paths = [ php php.packages.composer ] ++ envPackages; };
              }
          )
          {
            "default" = self'.packages.env-php81;
            "env-default" = self'.packages.env-php81;
          }
          phps;

        devShells = lib.foldlAttrs
          (
            carry: name: php:
              {
                "${name}" = pkgs.mkShellNoCC { name = "${name}"; buildInputs = [ php php.packages.composer ]; };
                "env-${name}" = self'.devShells."${name}".overrideAttrs (oldAttrs: { buildInputs = oldAttrs.buildInputs ++ envPackages; });
              } // carry
          )
          {
            "default" = self'.devShells.env-php81;
            "env-default" = self'.devShells.env-php81;
          }
          phps;
      in
      {
        _module.args.pkgs = import self.inputs.nixpkgs {
          inherit system;
          overlays = [
            self.overlays.default
          ];
          config.allowUnfree = true;
        };

        formatter = pkgs.nixpkgs-fmt;

        inherit packages devShells;
      };
  };
}
