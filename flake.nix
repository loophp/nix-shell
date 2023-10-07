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
        phps =
          (inputs.php-src-nix.overlays.snapshot pkgs pkgs) //
          (inputs.nix-phps.overlays.default pkgs pkgs);

        envPackages = [
          pkgs.symfony-cli
          pkgs.sqlite
        ];

        packages = lib.foldlAttrs
          (
            carry: name: php:
              carry // {
                "${name}" = pkgs."${name}";
                "env-${name}" = pkgs.buildEnv { name = "env-${name}"; paths = [ pkgs."${name}" pkgs."${name}".packages.composer ] ++ envPackages; };
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
                "${name}" = pkgs.mkShellNoCC { name = "${name}"; buildInputs = [ pkgs."${name}" pkgs."${name}".packages.composer ]; };
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
