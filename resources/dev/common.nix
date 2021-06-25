{
  pkgs ? (import <nixpkgs> {}),
  nix-phps ? import (fetchTarball https://github.com/fossar/nix-phps/archive/57fda5bb79afb05d0cac2c2f1025339250beb81c.tar.gz),
  version,
  phpIni,
  phpExtensions
}:

let
  phpOverride = nix-phps.packages.${builtins.currentSystem}.${version}.buildEnv {
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
