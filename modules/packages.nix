{
  inputs,
  ...
}:
{
  perSystem =
    { pkgs, config, ... }:
    {
      packages =
        (builtins.mapAttrs (
          _name: value:
          config.lib.buildPhpFromComposer {
            php = value;
            src = inputs.self;
          }
        ) pkgs.nix-phps)
        // {
          default = config.lib.buildPhpFromComposer {
            inherit (pkgs) php;
            src = inputs.self;
          };
        };
    };
}
