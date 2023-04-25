{
  description = "PHP/Composer/SymfonyCLi/GithubCLi/git/sqlite/make";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-phps.url = "github:fossar/nix-phps";
  };

  outputs = inputs @ {
    self,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      imports = [
        ./src/composer.nix
        ./src/phps.nix
      ];

      perSystem = {
        config,
        pkgs,
        system,
        ...
      }: let
        defaultPhpVersion = "php81";
        makePhp = self.api.makePhp system;
        envPackages = [
          pkgs.symfony-cli
          pkgs.gh
          pkgs.sqlite
          pkgs.git
          pkgs.gnumake
        ];

        packages =
          builtins.foldl' (
            carry: phpConfig: let
              pname = phpConfig.php;
              env-pname = "env-${pname}";
              php = makePhp phpConfig;
            in
              carry
              // {
                "${pname}" = php;
                "${env-pname}" = pkgs.buildEnv {
                  name = pname;
                  paths =
                    [
                      php
                      php.packages.composer
                    ]
                    ++ envPackages;
                };
              }
          ) {
            default = packages."${defaultPhpVersion}";
            env-default = packages."env-${defaultPhpVersion}";
          }
          self.api.matrix;

        devShells =
          builtins.foldl' (
            carry: phpConfig: let
              pname = phpConfig.php;
              env-pname = "env-${pname}";
              php = makePhp phpConfig;
            in
              carry
              // {
                "${pname}" = pkgs.mkShellNoCC {
                  name = pname;
                  buildInputs = [php];
                };
                "${env-pname}" = pkgs.mkShellNoCC {
                  name = env-pname;
                  buildInputs =
                    [
                      php
                      php.packages.composer
                    ]
                    ++ envPackages;
                };
              }
          ) {
            default = devShells."${defaultPhpVersion}";
            env-default = devShells."env-${defaultPhpVersion}";
          }
          self.api.matrix;
      in {
        inherit devShells packages;

        # TODO: Find a better way to do this.
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [inputs.nix-phps.overlays.default];
          config.allowUnfree = true;
          config.allowUnfreePredicate = (pkg: true);
        };

        formatter = pkgs.alejandra;
      };
    };
}
