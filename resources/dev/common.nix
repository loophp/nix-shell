{
  pkgs ? (import <nixpkgs> {}),
  nix-phps ? import (fetchTarball https://github.com/fossar/nix-phps/archive/31d86400860816d0f20406b336870a9ed31d5fbf.tar.gz),
  version ? "php74",
  phpIni ? ''
    max_execution_time = 0
    xdebug.mode=debug
    memory_limit=-1
    '',
  phpExtensions ? { all, ... }: with all; [
        # Mandatory
        filter
        iconv
        ctype
        redis
        tokenizer
        simplexml

        # Recommendations
        dom
        posix
        intl
        opcache

        # Optional
        calendar
        curl
        exif
        fileinfo
        gd
        mbstring
        openssl
        pcov
        pdo_sqlite
        pdo_mysql
        pdo_pgsql
        soap
        xdebug
        xmlreader
        xmlwriter
        zip
        zlib
    ]
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
