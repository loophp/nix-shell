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
        makePhp = self.api.makePhp pkgs;

        packages =
          inputs.nixpkgs.lib.mapAttrs'
          (
            name: phpConfig: let
              pname = phpConfig.php;
            in
              pkgs.lib.nameValuePair
              pname
              (makePhp phpConfig)
          )
          self.api.matrix
          // inputs.nixpkgs.lib.mapAttrs'
          (
            name: phpConfig: let
              pname = "env-${phpConfig.php}";
              php = makePhp phpConfig;

            in
              pkgs.lib.nameValuePair
              pname
              (pkgs.buildEnv {
                name = pname;
                paths = [
                  php
                  php.packages.composer
                  pkgs.symfony-cli
                  pkgs.gh
                  pkgs.sqlite
                  pkgs.git
                  pkgs.gnumake
                ];
              })
          )
          self.api.matrix;

        devShells =
          inputs.nixpkgs.lib.mapAttrs'
          (
            name: phpConfig: let
              pname = phpConfig.php;
            in
              pkgs.lib.nameValuePair
              pname
              (pkgs.mkShellNoCC {
                name = pname;
                buildInputs = [
                  (makePhp phpConfig)
                ];
              })
          )
          self.api.matrix
          // inputs.nixpkgs.lib.mapAttrs'
          (
            name: phpConfig: let
              pname = "env-${phpConfig.php}";
              php = makePhp phpConfig;
            in
              pkgs.lib.nameValuePair
              pname
              (pkgs.mkShellNoCC {
                name = pname;
                buildInputs = [
                  php
                  php.packages.composer
                  pkgs.symfony-cli
                  pkgs.gh
                  pkgs.sqlite
                  pkgs.git
                  pkgs.gnumake
                ];
              })
          )
          self.api.matrix;
      in {
        inherit devShells packages;

        # TODO: Find a better way to do this.
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [inputs.nix-phps.overlays.default];
          config.allowUnfree = true;
        };

        formatter = pkgs.alejandra;
      };
    };
}
