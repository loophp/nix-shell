{
  description = "PHP/Composer/SymfonyCLi/GithubCLi/git/sqlite/make";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-phps.url = "github:fossar/nix-phps";
  };

  outputs = { self, flake-utils, nixpkgs, nix-phps }:
  {
    overlays.default = import ./src/phps.nix nix-phps nixpkgs;
  } //
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              nix-phps.overlays.default
              self.overlays.default
            ];
            # This is only needed for the PHP oci8 extension.
            config = { allowUnfree = true; };
          };

          inherit (pkgs.loophp-nix-shell) matrix makePhp makePhpEnv;

          # Simple PHP environments
          shellEnvs = builtins.mapAttrs
            (
              name: phpConfig: pkgs.buildEnv
              {
                inherit name;

                paths = [
                  (makePhp pkgs phpConfig)
                ];
              }
            )
            matrix;

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
                    makePhpEnv pname (makePhp pkgs phpConfig) pkgs
                  )
            )
            matrix;

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
            matrix;

            # Augmented PHP development environments with other packages
            devShellsAugmented = nixpkgs.lib.mapAttrs'
            (
              name: phpConfig:
                let
                  pname = "env-" + name;
                  env = makePhpEnv pname (makePhp pkgs phpConfig);
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
            matrix;
        in
        {
          # In use for "nix shell"
          packages = shellEnvs // shellEnvsAugmented;

          # In use for "nix develop"
          devShells = devShells // devShellsAugmented;
        }
      );
}
