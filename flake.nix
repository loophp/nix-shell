{
  description = "PHP/Composer/SymfonyCLi/GithubCLi/git/sqlite/make";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    phps.url = "github:fossar/nix-phps";
    flake-compat = {
      url = github:edolstra/flake-compat;
      flake = false;
    };
  };

  outputs = { self, flake-utils, nixpkgs, phps }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config = { allowUnfree = true; };
          };
          lib = pkgs.lib;

          readJsonSectionFromFile = file: section: default:
            let
              filepath = "${builtins.getEnv "PWD"}/${file}";
              filecontent = if builtins.pathExists filepath then builtins.fromJSON (builtins.readFile filepath) else { };
            in
              filecontent.${section} or default;

          # Get "require" section to extract extensions later
          require = readJsonSectionFromFile "composer.json" "require" { };
          # Get "packages" section
          composerLockPackages = readJsonSectionFromFile "composer.lock" "packages" [ ];

          # Merge require from Composer with "require" section of each package from Composer lock to extract extensions later
          composerRequires = [ require ] ++ map (package: (if (package ? require) then package.require else { })) composerLockPackages;
          # Copy keys into values
          composerRequiresKeys = map (p: lib.attrsets.mapAttrs' (k: v: lib.nameValuePair k k) p) composerRequires;
          # Convert sets into lists
          composerRequiresMap = map (package: (map (key: builtins.getAttr key package) (builtins.attrNames package))) composerRequiresKeys;
          # Convert the set into a list, filter out values not starting with "ext-", get rid of the first 4 characters from the name
          userExtensions = map (x: builtins.substring 4 (builtins.stringLength x) x) (builtins.filter (x: (builtins.substring 0 4 x) == "ext-") (lib.flatten composerRequiresMap));

          extensionsGroups = {
            # List from https://symfony.com/doc/current/cloud/languages/php.html#default-php-extensions
            mandatory = [
              "bcmath"
              "calendar"
              "ctype"
              "curl"
              "dom"
              "exif"
              "fileinfo"
              "filter"
              "gd"
              "iconv"
              "intl"
              "mbstring"
              "opcache"
              "openssl"
              "pdo_sqlite"
              "pdo_mysql"
              "pdo_pgsql"
              "posix"
              "simplexml"
              "soap"
              "sodium"
              "sqlite3"
              "tokenizer"
              "xmlreader"
              "xmlwriter"
              "zip"
              "zlib"
            ] ++ userExtensions;
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
            , extensions ? extensionsGroups.mandatory
            , flags ? { }
            , extraConfig ? ""
            }:
            let
              uniqueExtensions = lib.unique (extensions);
              package = phps.packages.${system}."php${pkgs.lib.strings.replaceStrings [ "." ] [ "" ] version}";
              php = package.override flags;
              drvs = { all, ... }: (map (ext: all."${ext}") (builtins.filter (ext: all ? "${ext}") uniqueExtensions));
            in
            (php.buildEnv {
              inherit extraConfig;
              extensions = drvs;
            });

          derivations = rec
          {
            default = derivations.php81;
            default-nts = derivations.php81-nts;

            php56 = makePhp {
              version = "5.6";
              extensions = builtins.filter (x: !builtins.elem x [ "sodium" "pcov" ]) extensionsGroups.mandatory;
              inherit extraConfig;
            };

            php56-nts = makePhp {
              version = "5.6";
              extensions = builtins.filter (x: !builtins.elem x [ "sodium" "pcov" ]) extensionsGroups.mandatory;
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

            php71 = makePhp {
              version = "7.1";
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

            php72 = makePhp {
              version = "7.2";
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

            php73 = makePhp {
              version = "7.3";
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

            env-default = makePhpEnv "env-php-default" derivations.php81;
            env-default-nts = makePhpEnv "env-php-nts" derivations.php81-nts;

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
          };
        in
        {
          defaultPackage = derivations.default-nts;

          packages = derivations;

          devShell = pkgs.mkShellNoCC {
            name = derivations.default.name;
            buildInputs = [ derivations.default-nts ];
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
