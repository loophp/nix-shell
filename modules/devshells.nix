{
  inputs,
  ...
}:
{
  imports = [
    inputs.make-shell.flakeModules.default
  ];

  perSystem =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      envPackages = [
        pkgs.symfony-cli
        pkgs.sqlite
      ];
    in
    {
      make-shells = lib.foldlAttrs (
        carry: name: phpPackage:
        let
          buildInputs = [
            phpPackage
            phpPackage.packages.composer
          ];
        in
        {
          "${name}" = {
            inherit buildInputs;
            shellHook = ''
              echo "${builtins.readFile ../resources/shellHook.welcome-message-php.txt}"
            '';
          };
          "env-${name}" = {
            buildInputs = buildInputs ++ envPackages;
            shellHook = ''
              echo "${builtins.readFile ../resources/shellHook.welcome-message-php-env.txt}"
            '';
          };
        }
        // carry
      ) { } config.packages;
    };
}
