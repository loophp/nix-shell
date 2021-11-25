{
  pkgs,
  phps,
  version ? "php74",
  phpIni ? ''
    max_execution_time = 0
    xdebug.mode=debug
    memory_limit=2048M
    '',
  phpExtensions ? { all, ... }: with all; [],
  defaultExtensions ? { all, ... }: with all; []
}:

let
  defaultPhpExtensions = all: with all; [
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
    sqlite3
    xdebug
    xmlreader
    xmlwriter
    zip
    zlib
  ];

  phpOverride = phps.${version}.buildEnv {
    extensions = phpExtensions defaultPhpExtensions;
    extraConfig = phpIni;
  };

  mkShellNoCC = pkgs.mkShell.override { stdenv = pkgs.stdenvNoCC; };
in mkShellNoCC {
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

    pkgs.sqlite

    # Install Symfony CLi
    pkgs.symfony-cli

    # Install GNU Make
    pkgs.gnumake
  ];
}
