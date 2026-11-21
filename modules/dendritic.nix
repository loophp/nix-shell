{
  inputs,
  ...
}:
{
  flake-file = {
    formatter = pkgs: pkgs.nixfmt-rs;

    inputs = {
      flake-file.url = "github:denful/flake-file";

      flake-compat = {
        flake = false;
        url = "github:NixOS/flake-compat";
      };

      import-tree.url = "github:denful/import-tree";
    };
  };

  imports = [
    inputs.flake-file.flakeModules.dendritic
    inputs.flake-file.flakeModules.auto-follow
  ];

}
