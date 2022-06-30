nixpkgs:
nix-phps:

let
  composer = import ./composer.nix nixpkgs;

  # List from https://symfony.com/doc/current/cloud/languages/php.html#default-php-extensions
  defaultExtensions = [
    "bcmath"
    "calendar"
    "ctype"
    "curl"
    "dom"
    "exif"
    "fileinfo"
    "filter"
    "gd"
    "gettext"
    "gmp"
    "iconv"
    "intl"
    "mbstring"
    "mysqli"
    "mysqlnd"
    "opcache"
    "openssl"
    "pdo"
    "pdo_mysql"
    "pdo_odbc"
    "pdo_pgsql"
    "pdo_sqlite"
    "pgsql"
    "posix"
    "readline"
    "session"
    "simplexml"
    "sockets"
    "soap"
    "sodium"
    "sqlite3"
    "tokenizer"
    "xmlreader"
    "xmlwriter"
    "zip"
    "zlib"
  ];

  extensions = defaultExtensions ++ composer.getExtensionFromSection "require";
  devExtensions = composer.getExtensionFromSection "require-dev";

  phpMatrix = rec
  {
    default = phpMatrix.php81;

    php56 = {
      inherit devExtensions;
      extensions = extensions ++ [ "json" ];
      php = "php56";
      withoutExtensions = [ "sodium" "pcov" ];
    };

    php70 = {
      inherit devExtensions;
      extensions = extensions ++ [ "json" ];
      php = "php70";
      withoutExtensions = [ "sodium" ];
    };

    php71 = {
      inherit devExtensions;
      extensions = extensions ++ [ "json" ];
      php = "php71";
      withoutExtensions = [ "sodium" ];
    };

    php72 = {
      inherit devExtensions;
      extensions = extensions ++ [ "json" ];
      php = "php72";
    };

    php73 = {
      inherit devExtensions;
      extensions = extensions ++ [ "json" ];
      php = "php73";
    };

    php74 = {
      inherit devExtensions;
      extensions = extensions ++ [ "json" ];
      php = "php74";
    };

    php80 = {
      inherit extensions;
      inherit devExtensions;
      php = "php80";
    };

    php81 = {
      inherit extensions;
      inherit devExtensions;
      php = "php81";
    };

    php82 = {
      inherit extensions;
      inherit devExtensions;
      php = "php82";
    };
  };

  # Build NTS versions.
  matrix = phpMatrix // nixpkgs.lib.mapAttrs' (name: php:
    nixpkgs.lib.nameValuePair
      (name + "-nts")
      (
        php // {
          flags = {
            apxs2Support = false;
            ztsSupport = false;
          };
        }
      )
    ) phpMatrix;

  makePhp =
    nixpkgs:
    nix-phps:
    system:
    {
    php
    , extensions ? [ ]
    , withoutExtensions ? [ ]
    , extraConfig ? ""
    , extraConfigFile ? "${builtins.getEnv "PWD"}/.user.ini"
    , flags ? { }
    }:
    let
      pkgs = import ./pkgs.nix nixpkgs system;
      nixphps = import ./nixphps.nix nix-phps system;

      withExtensions = builtins.filter
        (x: !builtins.elem x withoutExtensions)
        (pkgs.lib.unique (if extensions == [] then phpMatrix."${php}".extensions or [] else extensions));

      phpDrv = if builtins.isString php then (nixphps."${php}" or pkgs."${php}") else php;
    in
    ((phpDrv.override flags).buildEnv {
      extraConfig = extraConfig + "\n" + (if builtins.pathExists "${extraConfigFile}" then builtins.readFile "${extraConfigFile}" else "");
      extensions = { all, ... }: (
        map
          (ext: if builtins.isString ext then all."${ext}" else ext)
          (
            builtins.filter
              (ext: if builtins.isString ext then all ? "${ext}" else ext)
              withExtensions
          )
      );
    });

  makePhpEnv = system: name: php:
  let
    pkgs = import ./pkgs.nix nixpkgs system;
  in
  pkgs.buildEnv {
    inherit name;

    paths = [
      php
      php.packages.composer
      pkgs.symfony-cli
      pkgs.gh
      pkgs.sqlite
      pkgs.git
      pkgs.gnumake
    ];
  };

  phps = {
    matrix = matrix;
    makePhp = makePhp nixpkgs nix-phps;
    makePhpEnv = makePhpEnv;
  };
in
  phps