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
          file = "";
          name = "lib";

          option = lib.mkOption {
            default = { };
            type = lib.types.lazyAttrsOf lib.types.anything;
          };
        };
    in
    [
      libOutputModule
    ];
}
