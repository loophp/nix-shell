{
  description = "PHP/Composer/SymfonyCLi/GithubCLi/git/sqlite/make";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
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
          pkgs = import ./src/pkgs.nix nixpkgs nix-phps system;

          makePhp = phps.makePhp system;
          makePhpEnv = phps.makePhpEnv system;

          # Simple PHP environments
          shellEnvs = builtins.mapAttrs
            (
              name: phpConfig: pkgs.buildEnv
              {
                inherit name;

                paths = [
                  (makePhp phpConfig)
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
                in
                pkgs.lib.nameValuePair
                  (pname)
                  (
                    makePhpEnv pname (makePhp phpConfig)
                  )
            )
            phps.matrix;

            # Simple PHP development environments
            devShells = builtins.mapAttrs
            (
              name: phpConfig: pkgs.mkShellNoCC {
                inherit name;

                buildInputs = [
                  (makePhp phpConfig)
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
                  env = makePhpEnv pname (makePhp phpConfig);
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
