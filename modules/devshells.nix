{
  inputs,
  ...
}:
{
  flake-file.inputs = {
    make-shell.url = "github:nicknovitski/make-shell";
  };

  imports = [
    inputs.make-shell.flakeModules.default
  ];

  perSystem =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      envPackages = [
        pkgs.symfony-cli
        pkgs.sqlite
      ];
      formatPackage =
        package:
        let
          homepage = metadata.homepage or (getHomepage package);
          metadata = packageMetadata.${pname} or { };
          name = metadata.name or pname;
          pname = package.pname or (lib.getName package);
          version = package.version or (lib.getVersion package);
        in
        "- ${name} ${version}" + lib.optionalString (homepage != null) " (${homepage})";
      getHomepage =
        package:
        let
          homepage = if package ? meta && package.meta ? homepage then package.meta.homepage else null;
        in
        if builtins.isList homepage then
          if homepage == [ ] then null else builtins.head homepage
        else
          homepage;
      mkMotd =
        buildInputs:
        let
          packages = lib.concatMapStringsSep "\n" formatPackage buildInputs;
        in
        pkgs.runCommand "php-development-shell-motd" { inherit packages; } ''
          substitute ${../resources/shellHook.welcome-message-php.txt} "$out" \
            --subst-var packages
        '';
      mkShell = buildInputs: {
        inherit buildInputs;

        shellHook = ''
          cat "${mkMotd buildInputs}"
        '';
      };
      packageMetadata = {
        composer = {
          name = "Composer";
        };

        php = {
          name = "PHP";
        };

        php-with-extensions = {
          name = "PHP";
        };

        sqlite = {
          name = "SQLite";
        };

        symfony-cli = {
          name = "Symfony CLI";
        };
      };
      phpPackages = lib.filterAttrs (
        name: _:
        !(builtins.elem name [
          "write-flake"
          "write-inputs"
          "write-lock"
        ])
      ) config.packages;
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
        carry
        // {
          "${name}" = mkShell buildInputs;
          "env-${name}" = mkShell (buildInputs ++ envPackages);
        }
      ) { } phpPackages;
    };
}
