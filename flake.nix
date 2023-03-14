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

      flake = {
        api = import ./src/phps.nix inputs.nixpkgs inputs.nix-phps;
      };

      perSystem = {
        config,
        pkgs,
        system,
        ...
      }: let
        pkgs = import ./src/pkgs.nix inputs.nixpkgs inputs.nix-phps system;

        makePhp = self.api.makePhp system;
        makePhpEnv = self.api.makePhpEnv system;

        packages =
          builtins.mapAttrs
          (
            name: phpConfig:
              pkgs.buildEnv
              {
                inherit name;

                paths = [
                  (makePhp phpConfig)
                ];
              }
          )
          self.api.matrix
          // inputs.nixpkgs.lib.mapAttrs'
          (
            name: phpConfig: let
              pname = "env-" + name;
            in
              pkgs.lib.nameValuePair
              pname
              (
                makePhpEnv pname (makePhp phpConfig)
              )
          )
          self.api.matrix;

        devShells =
          (builtins.mapAttrs
            (
              name: phpConfig:
                pkgs.mkShellNoCC {
                  inherit name;

                  buildInputs = [
                    (makePhp phpConfig)
                  ];
                }
            )
            self.api.matrix)
          // inputs.nixpkgs.lib.mapAttrs'
          (
            name: phpConfig: let
              pname = "env-" + name;
            in
              pkgs.lib.nameValuePair
              pname
              (
                pkgs.mkShellNoCC {
                  name = pname;

                  buildInputs = [
                    (makePhpEnv pname (makePhp phpConfig))
                  ];
                }
              )
          )
          self.api.matrix;
      in {
        formatter = pkgs.alejandra;

        packages = packages;

        devShells = devShells;
      };
    };
}
