{
  inputs,
  ...
}:
{
  flake-file = {
    formatter = pkgs: pkgs.nixfmt-rs;

    inputs = {
      flake-file.url = "github:denful/flake-file";
      import-tree.url = "github:denful/import-tree";
    };

    outputs = "inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules)";
  };

  imports = [
    inputs.flake-file.flakeModules.dendritic
    inputs.flake-file.flakeModules.auto-follow
  ];

}
