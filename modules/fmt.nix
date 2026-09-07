{ inputs, ... }:
{
  flake-file.inputs = {
    json-sort.url = "github:drupol/json-sort";
    pedantix.url = "github:swarsel/pedantix";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  imports = [
    inputs.treefmt-nix.flakeModule
    inputs.pedantix.flakeModules.default
  ];

  perSystem =
    { pkgs, ... }:
    {
      treefmt = {
        programs = {
          deadnix.enable = true;
          jsonfmt.enable = true;

          nixfmt = {
            enable = true;
            package = pkgs.nixfmt-rs;
          };

          oxfmt.enable = true;

          pedantix = {
            enable = true;

            excludes = [
              "flake.nix"
              "default.nix"
              "shell.nix"
            ];

            package = pkgs.pedantix;
            priority = -2;
          };

          shfmt.enable = true;
          statix.enable = true;
          yamlfmt.enable = true;
        };

        projectRootFile = "flake.nix";

        settings = {
          on-unmatched = "warn";
        };
      };
    };
}
