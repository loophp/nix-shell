{ pkgs, phpPkg, phpIni, phpExtensions }:
with pkgs;
let
    php = phpPkg;

    phpOverride = php.buildEnv {
      extensions = phpExtensions;
      extraConfig = phpIni;
    };

in mkShell {
  name = "php74-dev";

  buildInputs = [
    # Install PHP and composer
    phpOverride
    phpOverride.packages.composer

    # Install Github CLi
    gh

    # Install Symfony CLi
    symfony-cli

    # Install GNU Make for shorthands
    gnumake
  ];
}
