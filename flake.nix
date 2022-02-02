{
  description = "PHP/Composer/SymfonyCLi/GithubCLi/git/sqlite/make";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    phps.url = "github:fossar/nix-phps";
  };

  outputs = { self, flake-utils, nixpkgs, phps }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config = { allowUnfree = true; };
          };

          extensionsGroups = {
            mandatory = [
              "bcmath"
              "filter"
              "iconv"
              "ctype"
              "redis"
              "tokenizer"
              "simplexml"
              "sodium"
              "dom"
              "posix"
              "intl"
              "opcache"
            ];

            optional = [
              "calendar"
              "curl"
              "exif"
              "fileinfo"
              "gd"
              "mbstring"
              "openssl"
              "pdo_sqlite"
              "pdo_mysql"
              "pdo_pgsql"
              "soap"
              "sqlite3"
              "xmlreader"
              "xmlwriter"
              "zip"
              "zlib"
            ];

            useful = [
              "ds"
            ];

            debug = [
              "pcov"
              "xdebug"
            ];
          };

          phpIniFile = "${builtins.getEnv "PWD"}/.php.ini";
          extraConfig = if builtins.pathExists "${phpIniFile}" then builtins.readFile "${phpIniFile}" else "";
          makePhpEnv = name: php: pkgs.buildEnv {
            inherit name;
            paths = [
              php
              php.packages.composer
            ] ++ [
              pkgs.symfony-cli
              pkgs.gh
              pkgs.sqlite
              pkgs.git
              pkgs.gnumake
            ];
          };

          makePhp =
            { version ? "8.1"
            , extensions ? extensionsGroups.mandatory ++ extensionsGroups.optional ++ extensionsGroups.debug
            , flags ? { }
            , extraConfig ? ""
            }:
            let
              package = phps.packages.${system}."php${pkgs.lib.strings.replaceStrings [ "." ] [ "" ] version}";
              php = package.override flags;
              drvs = map (ext: php.extensions."${ext}") extensions;
            in
            (php.buildEnv {
              inherit extraConfig;
              extensions = { all, ... }: drvs;
            });

          derivations = rec
          {
            default = derivations.php81;
            default-nodebug = derivations.php81-nodebug;
            default-nts = derivations.php81-nts;
            default-nts-nodebug = derivations.php81-nts-nodebug;

            php56 = makePhp {
              version = "5.6";
              extensions = builtins.filter (x: !builtins.elem x [ "sodium" "pcov" ]) (extensionsGroups.mandatory ++ extensionsGroups.optional ++ extensionsGroups.debug);
              inherit extraConfig;
            };

            php56-nodebug = makePhp {
              version = "5.6";
              extensions = builtins.filter (x: !builtins.elem x [ "sodium" ]) (extensionsGroups.mandatory ++ extensionsGroups.optional);
              inherit extraConfig;
            };

            php56-nts = makePhp {
              version = "5.6";
              extensions = builtins.filter (x: !builtins.elem x [ "sodium" "pcov" ]) (extensionsGroups.mandatory ++ extensionsGroups.optional ++ extensionsGroups.debug);
              flags = {
                apxs2Support = false;
                ztsSupport = false;
              };
              inherit extraConfig;
            };

            php56-nts-nodebug = makePhp {
              version = "5.6";
              extensions = builtins.filter (x: !builtins.elem x [ "sodium" ]) (extensionsGroups.mandatory ++ extensionsGroups.optional);
              flags = {
                apxs2Support = false;
                ztsSupport = false;
              };
              inherit extraConfig;
            };

            php70 = makePhp {
              version = "7.0";
              inherit extraConfig;
            };

            php70-nts = makePhp {
              version = "7.0";
              flags = {
                apxs2Support = false;
                ztsSupport = false;
              };
              inherit extraConfig;
            };

            php70-nodebug = makePhp {
              version = "7.0";
              extensions = extensionsGroups.mandatory ++ extensionsGroups.optional;
              inherit extraConfig;
            };

            php70-nts-nodebug = makePhp {
              version = "7.0";
              extensions = extensionsGroups.mandatory ++ extensionsGroups.optional;
              flags = {
                apxs2Support = false;
                ztsSupport = false;
              };
              inherit extraConfig;
            };

            php71 = makePhp {
              version = "7.1";
              inherit extraConfig;
            };

            php71-nodebug = makePhp {
              version = "7.1";
              extensions = extensionsGroups.mandatory ++ extensionsGroups.optional;
              inherit extraConfig;
            };

            php71-nts = makePhp {
              version = "7.1";
              flags = {
                apxs2Support = false;
                ztsSupport = false;
              };
              inherit extraConfig;
            };

            php71-nts-nodebug = makePhp {
              version = "7.1";
              extensions = extensionsGroups.mandatory ++ extensionsGroups.optional;
              flags = {
                apxs2Support = false;
                ztsSupport = false;
              };
              inherit extraConfig;
            };

            php72 = makePhp {
              version = "7.2";
              inherit extraConfig;
            };

            php72-nodebug = makePhp {
              version = "7.2";
              extensions = extensionsGroups.mandatory ++ extensionsGroups.optional;
              inherit extraConfig;
            };

            php72-nts = makePhp {
              version = "7.2";
              flags = {
                apxs2Support = false;
                ztsSupport = false;
              };
              inherit extraConfig;
            };

            php72-nts-nodebug = makePhp {
              version = "7.2";
              extensions = extensionsGroups.mandatory ++ extensionsGroups.optional;
              flags = {
                apxs2Support = false;
                ztsSupport = false;
              };
              inherit extraConfig;
            };

            php73 = makePhp {
              version = "7.3";
              inherit extraConfig;
            };

            php73-nodebug = makePhp {
              version = "7.3";
              extensions = extensionsGroups.mandatory ++ extensionsGroups.optional;
              inherit extraConfig;
            };

            php73-nts = makePhp {
              version = "7.3";
              flags = {
                apxs2Support = false;
                ztsSupport = false;
              };
              inherit extraConfig;
            };

            php73-nts-nodebug = makePhp {
              version = "7.3";
              extensions = extensionsGroups.mandatory ++ extensionsGroups.optional;
              flags = {
                apxs2Support = false;
                ztsSupport = false;
              };
              inherit extraConfig;
            };

            php74 = makePhp {
              version = "7.4";
              inherit extraConfig;
            };

            php74-nts = makePhp {
              version = "7.4";
              flags = {
                apxs2Support = false;
                ztsSupport = false;
              };
              inherit extraConfig;
            };

            php74-nodebug = makePhp {
              version = "7.4";
              extensions = extensionsGroups.mandatory ++ extensionsGroups.optional;
              inherit extraConfig;
            };

            php74-nts-nodebug = makePhp {
              version = "7.4";
              extensions = extensionsGroups.mandatory ++ extensionsGroups.optional;
              flags = {
                apxs2Support = false;
                ztsSupport = false;
              };
              inherit extraConfig;
            };

            php80 = makePhp {
              version = "8.0";
              inherit extraConfig;
            };

            php80-nts = makePhp {
              version = "8.0";
              flags = {
                apxs2Support = false;
                ztsSupport = false;
              };
              inherit extraConfig;
            };

            php80-nodebug = makePhp {
              version = "8.0";
              extensions = extensionsGroups.mandatory ++ extensionsGroups.optional;
              inherit extraConfig;
            };

            php80-nts-nodebug = makePhp {
              version = "8.0";
              extensions = extensionsGroups.mandatory ++ extensionsGroups.optional;
              flags = {
                apxs2Support = false;
                ztsSupport = false;
              };
              inherit extraConfig;
            };

            php81 = makePhp {
              version = "8.1";
              inherit extraConfig;
            };

            php81-nts = makePhp {
              version = "8.1";
              flags = {
                apxs2Support = false;
                ztsSupport = false;
              };
              inherit extraConfig;
            };

            php81-nodebug = makePhp {
              version = "8.1";
              extensions = extensionsGroups.mandatory ++ extensionsGroups.optional;
              inherit extraConfig;
            };

            php81-nts-nodebug = makePhp {
              version = "8.1";
              extensions = extensionsGroups.mandatory ++ extensionsGroups.optional;
              flags = {
                apxs2Support = false;
                ztsSupport = false;
              };
              inherit extraConfig;
            };

            env-default = makePhpEnv "env-php-default" derivations.php81;
            env-default-nodebug = makePhpEnv "env-php-default-nodebug" derivations.php81-nodebug;
            env-default-nts = makePhpEnv "env-php-nts" derivations.php81-nts;
            env-default-nts-nodebug = makePhpEnv "env-php-nts-nodebug" derivations.php81-nts-nodebug;

            env-php56 = makePhpEnv "env-php56" php56;
            env-php71 = makePhpEnv "env-php71" php71;
            env-php72 = makePhpEnv "env-php72" php72;
            env-php73 = makePhpEnv "env-php73" php73;
            env-php74 = makePhpEnv "env-php74" php74;
            env-php80 = makePhpEnv "env-php80" php80;
            env-php81 = makePhpEnv "env-php81" php81;

            env-php56-nts = makePhpEnv "env-php56-nts" php56-nts;
            env-php71-nts = makePhpEnv "env-php71-nts" php71-nts;
            env-php72-nts = makePhpEnv "env-php72-nts" php72-nts;
            env-php73-nts = makePhpEnv "env-php73-nts" php73-nts;
            env-php74-nts = makePhpEnv "env-php74-nts" php74-nts;
            env-php80-nts = makePhpEnv "env-php80-nts" php80-nts;
            env-php81-nts = makePhpEnv "env-php81-nts" php81-nts;

            env-php56-nodebug = makePhpEnv "env-php56-nodebug" php56-nodebug;
            env-php71-nodebug = makePhpEnv "env-php71-nodebug" php71-nodebug;
            env-php72-nodebug = makePhpEnv "env-php72-nodebug" php72-nodebug;
            env-php73-nodebug = makePhpEnv "env-php73-nodebug" php73-nodebug;
            env-php74-nodebug = makePhpEnv "env-php74-nodebug" php74-nodebug;
            env-php80-nodebug = makePhpEnv "env-php80-nodebug" php80-nodebug;
            env-php81-nodebug = makePhpEnv "env-php81-nodebug" php81-nodebug;

            env-php56-nts-nodebug = makePhpEnv "env-php56-nts-nodebug" php56-nts-nodebug;
            env-php71-nts-nodebug = makePhpEnv "env-php71-nts-nodebug" php71-nts-nodebug;
            env-php72-nts-nodebug = makePhpEnv "env-php72-nts-nodebug" php72-nts-nodebug;
            env-php73-nts-nodebug = makePhpEnv "env-php73-nts-nodebug" php73-nts-nodebug;
            env-php74-nts-nodebug = makePhpEnv "env-php74-nts-nodebug" php74-nts-nodebug;
            env-php80-nts-nodebug = makePhpEnv "env-php80-nts-nodebug" php80-nts-nodebug;
            env-php81-nts-nodebug = makePhpEnv "env-php81-nts-nodebug" php81-nts-nodebug;
          };
        in
        {
          defaultPackage = derivations.default;

          packages = derivations;

          devShell = pkgs.mkShellNoCC {
            name = derivations.default.name;
            buildInputs = [ derivations.default ];
          };

          devShells = builtins.mapAttrs
            (name: value: pkgs.mkShellNoCC {
              inherit name;
              buildInputs = [ value ];
            })
            derivations;
        }
      );
}
