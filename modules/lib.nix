{
  inputs,
  ...
}:
{
  imports =
    let
      libOutputModule =
        { lib, ... }:
        inputs.flake-parts.lib.mkTransposedPerSystemModule {
          name = "lib";
          option = lib.mkOption {
            type = lib.types.lazyAttrsOf lib.types.anything;
            default = { };
          };
          file = "";
        };
    in
    [
      libOutputModule
    ];
}
