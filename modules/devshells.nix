{ inputs, ... }:
{
  perSystem =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      buildPhpFromComposer = pkgs.callPackage ../src/build-support/build-php-from-composer.nix { };

      phps =
        lib.mapAttrs
          # To fix: Why using this while it is already in use in the overlay?
          (
            _name: value:
            buildPhpFromComposer {
              php = value;
              src = inputs.self;
            }
          )
          (lib.filterAttrs (_k: v: lib.isDerivation v) (inputs.self.overlays.default null pkgs));

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
                ]
                ++ envPackages;
              };
            }
          )
          {
            "default" = config.packages.env-php82;
            "env-default" = config.packages.env-php82;
          }
          phps;

    in
    {
      inherit packages;

      devShells =
        lib.foldlAttrs
          (
            carry: name: php:
            {
              "${name}" = pkgs.mkShellNoCC {
                name = "${name}";
                packages = [
                  php
                  php.packages.composer
                ];
              };
              "env-${name}" = config.devShells."${name}".overrideAttrs (oldAttrs: {
                packages = oldAttrs.packages ++ envPackages;
              });
            }
            // carry
          )
          {
            "default" = config.devShells.env-php82;
            "env-default" = config.devShells.env-php82;
          }
          phps;
    };
}
