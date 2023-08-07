{
  description = "PHP/Composer/SymfonyCLi/GithubCLi/git/sqlite/make";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-phps.url = "github:fossar/nix-phps";
    mkshell-minimal.url = "github:viperML/mkshell-minimal";
    nix-php-composer-builder.url = "github:loophp/nix-php-composer-builder";

    # Shim to make flake.nix work with stable Nix.
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    systems.url = "github:nix-systems/default";
  };

  outputs = inputs @ { self, flake-parts, mkshell-minimal, systems, ... }: flake-parts.lib.mkFlake { inherit inputs; } {
    systems = import systems;

    imports = [
      inputs.flake-parts.flakeModules.easyOverlay
    ];

    perSystem = { config, pkgs, system, ... }:
      let
        phps = map
          (php: pkgs.api.buildPhpFromComposer { inherit php; src = inputs.self; })
          (builtins.attrNames inputs.nix-phps.packages."${system}");

        envPackages = [
          pkgs.symfony-cli
          pkgs.gh
          pkgs.sqlite
          pkgs.gnumake
        ];

        packages = builtins.foldl'
          (
            carry: php:
              let
                name = "php${pkgs.lib.versions.major php.version}${pkgs.lib.versions.minor php.version}";
              in
              {
                "${name}" = php;
                "env-${name}" = pkgs.buildEnv { name = "env-${name}"; paths = [ php php.packages.composer ] ++ envPackages; };
              } // carry
          )
          {
            "default" = self.packages."${system}".env-php81;
            "env-default" = self.packages."${system}".env-php81;
          }
          phps;

        devShells = builtins.foldl'
          (
            carry: php:
              let
                name = "php${pkgs.lib.versions.major php.version}${pkgs.lib.versions.minor php.version}";
              in
              {
                "${name}" = mkshell-minimal pkgs { name = "${name}"; packages = [ php php.packages.composer ]; };
                "env-${name}" = mkshell-minimal pkgs { name = "env-${name}"; packages = [ php php.packages.composer ] ++ envPackages; };
              } // carry
          )
          {
            "default" = self.devShells."${system}".env-php81;
            "env-default" = self.devShells."${system}".env-php81;
          }
          phps;
      in
      {
        _module.args.pkgs = import self.inputs.nixpkgs {
          inherit system;
          overlays = [
            inputs.nix-phps.overlays.default
            inputs.nix-php-composer-builder.overlays.default
          ];
          config.allowUnfree = true;
        };

        formatter = pkgs.nixpkgs-fmt;

        overlayAttrs = packages;

        inherit packages devShells;
      };
  };
}
