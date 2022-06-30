{
  description = "PHP/Composer/SymfonyCLi/GithubCLi/git/sqlite/make";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.nixpkgs.follows = "nixpkgs";
    nix-phps.url = "github:fossar/nix-phps";
  };

  outputs = { self, flake-utils, nixpkgs, nix-phps }:
  let
    phps = import ./src/phps.nix nixpkgs nix-phps;

    api = phps;
  in {
    inherit api;
  } //
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import ./src/pkgs.nix nixpkgs system;

          makePhp = phps.makePhp system;
          makePhpEnv = phps.makePhpEnv system;

          # Simple PHP environments
          shellEnvs = builtins.mapAttrs
            (
              name: phpConfig:
              let
                phpConfigUpdated = (builtins.removeAttrs phpConfig ["devExtensions"]);
              in
              pkgs.buildEnv
              {
                inherit name;

                paths = [
                  (makePhp phpConfigUpdated)
                ];
              }
            )
            phps.matrix;

          # Augmented PHP environments with other packages
          shellEnvsAugmented = nixpkgs.lib.mapAttrs'
            (
              name: phpConfig:
                let
                  pname = "env-" + name;
                  phpConfigUpdated = (builtins.removeAttrs phpConfig ["devExtensions"]);
                in
                pkgs.lib.nameValuePair
                  (pname)
                  (
                    makePhpEnv pname (makePhp phpConfigUpdated)
                  )
            )
            phps.matrix;

            # Simple PHP development environments
            devShells = builtins.mapAttrs
            (
              name: phpConfig:
                let
                  pname = name;
                  phpConfigUpdated = phpConfig // { extensions = phpConfig.extensions ++ phpConfig.devExtensions; };
                  php = makePhp (builtins.removeAttrs phpConfigUpdated ["devExtensions"]);
                in
                  pkgs.mkShellNoCC {
                    name = pname;

                    buildInputs = [
                      php
                    ];
                  }
            )
            phps.matrix;

            # Augmented PHP development environments with other packages
            devShellsAugmented = nixpkgs.lib.mapAttrs'
            (
              name: phpConfig:
                let
                  pname = "env-" + name;
                  phpConfigUpdated = phpConfig // { extensions = phpConfig.extensions ++ phpConfig.devExtensions; };
                  php = makePhp (builtins.removeAttrs phpConfigUpdated ["devExtensions"]);
                  env = makePhpEnv pname php;
                in
                pkgs.lib.nameValuePair
                  (pname)
                  (
                    pkgs.mkShellNoCC {
                      name = pname;

                      buildInputs = [
                        env
                      ];
                    }
                  )
            )
            phps.matrix;
        in
        {
          # In use for "nix shell"
          packages = shellEnvs // shellEnvsAugmented;

          # In use for "nix develop"
          devShells = devShells // devShellsAugmented;
        }
      );
}
