{ pkgs, phpPkg, phpIni, phpExtensions }:
with pkgs;
let
    php = phpPkg;

    phpOverride = php.buildEnv {
      extensions = phpExtensions;
      extraConfig = phpIni;
    };

in mkShell {
  name = "php-" + phpOverride.version;

  buildInputs = [
    # Install PHP and composer
    phpOverride
    phpOverride.packages.composer

    # Install Git
    git

    # Install docker-compose
    docker-compose

    # Install Github CLi
    gh

    # Install Symfony CLi
    symfony-cli

    # Install GNU Make
    gnumake
  ];
}
