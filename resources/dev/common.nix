{ pkgs
, phps
, version
, apxs2Support
, phpExtensions ? { all, ... }: with all; [ ]
, defaultExtensions ? { all, ... }: with all; [ ]
}:

let
  defaultPhpExtensions = all: with all; [
    # Mandatory
    bcmath
    filter
    iconv
    ctype
    redis
    tokenizer
    simplexml
    sodium

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

  # This is the reason why we use --impure flag.
  phpIniFile = "${builtins.getEnv "PWD"}/.php.ini";

  phpOverride = (phps.${version}.override { apxs2Support = apxs2Support; }).buildEnv {
    extensions = phpExtensions defaultPhpExtensions;
    extraConfig = if builtins.pathExists "${phpIniFile}" then builtins.readFile "${phpIniFile}" else "";
  };

  mkShellNoCC = pkgs.mkShell.override { stdenv = pkgs.stdenvNoCC; };
in
mkShellNoCC {
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
