{
  description = "PHP/Composer/SymfonyCLi/GithubCLi/git/sqlite/make";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-phps.url = "github:fossar/nix-phps";
  };

  outputs = inputs @ {flake-parts, ...}: let
    phps = import ./src/phps.nix inputs.nixpkgs inputs.nix-phps;
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      flake = {
        api = phps;
      };

      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem = {
        config,
        pkgs,
        system,
        ...
      }: let
        pkgs = import ./src/pkgs.nix inputs.nixpkgs inputs.nix-phps system;

        makePhp = phps.makePhp system;
        makePhpEnv = phps.makePhpEnv system;

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
          phps.matrix
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
          phps.matrix;

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
            phps.matrix)
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
          phps.matrix;
      in {
        formatter = pkgs.alejandra;

        packages = packages;

        devShells = devShells;
      };
    };
}
