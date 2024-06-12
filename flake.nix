{
  description = "PHP/Composer/SymfonyCLi/GithubCLi/git/sqlite/make";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-phps.url = "github:fossar/nix-phps";
    # Shim to make flake.nix work with stable Nix.
    flake-compat.url = "github:nix-community/flake-compat";
    systems.url = "github:nix-systems/default";
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      imports = [
        ./src/imports/formatter.nix
        ./src/imports/overlay.nix
        ./src/imports/templates.nix
      ];

      flake = {
        overlays.default = import ./src/overlay inputs;
      };

      perSystem =
        {
          self',
          pkgs,
          lib,
          ...
        }:
        let
          buildPhpFromComposer = pkgs.callPackage ./src/build-support/build-php-from-composer.nix { };

          phps =
            lib.mapAttrs
              # To fix: Why using this while it is already in use in the overlay?
              (
                name: value:
                buildPhpFromComposer {
                  php = value;
                  src = self;
                }
              )
              (lib.filterAttrs (k: v: lib.isDerivation v) (inputs.self.overlays.default null pkgs));

          envPackages = [
            pkgs.symfony-cli
            pkgs.sqlite
          ];

          packages =
            lib.foldlAttrs
              (
                carry: name: php:
                carry
                // {
                  "${name}" = php;
                  "env-${name}" = pkgs.buildEnv {
                    name = "env-${name}";
                    paths = [
                      php
                      php.packages.composer
                    ] ++ envPackages;
                  };
                }
              )
              {
                "default" = self'.packages.env-php81;
                "env-default" = self'.packages.env-php81;
              }
              phps;

          devShells =
            lib.foldlAttrs
              (
                carry: name: php:
                {
                  "${name}" = pkgs.mkShellNoCC {
                    name = "${name}";
                    buildInputs = [
                      php
                      php.packages.composer
                    ];
                  };
                  "env-${name}" = self'.devShells."${name}".overrideAttrs (oldAttrs: {
                    buildInputs = oldAttrs.buildInputs ++ envPackages;
                  });
                }
                // carry
              )
              {
                "default" = self'.devShells.env-php81;
                "env-default" = self'.devShells.env-php81;
              }
              phps;
        in
        {
          inherit packages devShells;
        };
    };
}
