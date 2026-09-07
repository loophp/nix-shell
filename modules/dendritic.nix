{
  inputs,
  ...
}:
{
  flake-file = {
    inputs = {
      flake-file.url = "github:denful/flake-file";
      import-tree.url = "github:denful/import-tree";
    };
  };

  imports = [
    inputs.flake-file.flakeModules.dendritic
    inputs.flake-file.flakeModules.auto-follow
  ];

}
