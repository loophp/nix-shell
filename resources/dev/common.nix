{
  pkgs ? (import <nixpkgs> {}),
  version,
  phpIni,
  phpExtensions
}:

let
    phpOverride = pkgs.${version}.buildEnv {
      extensions = phpExtensions;
      extraConfig = phpIni;
    };

in pkgs.mkShell {
  name = "php-" + phpOverride.version;

  buildInputs = [
    # Install PHP and composer
    phpOverride
    phpOverride.packages.composer

    # Install Git
    pkgs.git

    # Install docker-compose
    pkgs.docker-compose

    # Install Github CLi
    pkgs.gh

    # Install Symfony CLi
    pkgs.symfony-cli

    # Install GNU Make
    pkgs.gnumake
  ];
}
