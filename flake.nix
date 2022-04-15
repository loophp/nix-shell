{
  description = "PHP/Composer/SymfonyCLi/GithubCLi/git/sqlite/make";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-phps.url = "github:fossar/nix-phps";
  };

  outputs = { self, flake-utils, nixpkgs, nix-phps }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config = { allowUnfree = true; };
          };

          # Why can't we rewrite this with an "import" ?
          phps = nix-phps.packages.${system};

          lib = pkgs.lib;

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
            "json"
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

          getExtensionFromComposerSection = section:
            let
              readJsonSectionFromFile = file: section: default:
                let
                  filepath = "${builtins.getEnv "PWD"}/${file}";
                  filecontent = if builtins.pathExists filepath then builtins.fromJSON (builtins.readFile filepath) else { };
                in
                  filecontent.${section} or default;

              # Get "require" section to extract extensions later
              require = readJsonSectionFromFile "composer.json" section { };
              # Copy keys into values
              composerRequiresKeys = map (p: lib.attrsets.mapAttrs' (k: v: lib.nameValuePair k k) p) [ require ];
              # Convert sets into lists
              composerRequiresMap = map (package: (map (key: builtins.getAttr key package) (builtins.attrNames package))) composerRequiresKeys;
            in
              # Convert the set into a list, filter out values not starting with "ext-", get rid of the first 4 characters from the name
              map (x: builtins.substring 4 (builtins.stringLength x) x) (builtins.filter (x: (builtins.substring 0 4 x) == "ext-") (lib.flatten composerRequiresMap));

          requiredExts = getExtensionFromComposerSection "require";
          requiredDevExts = getExtensionFromComposerSection "require-dev";

          makePhp =
            { php
            , withExtensions ? [ ]
            , withoutExtensions ? [ ]
            , extraConfig ? ""
            , flags ? { }
            }:
            let
              phpIniFile = "${builtins.getEnv "PWD"}/.user.ini";
              extensions = builtins.filter (x: !builtins.elem x withoutExtensions) (lib.unique withExtensions);
            in
            ((php.override flags).buildEnv {
              extraConfig = extraConfig + "\n" + (if builtins.pathExists "${phpIniFile}" then builtins.readFile "${phpIniFile}" else "");
              extensions = { all, ... }: (map (ext: all."${ext}") (builtins.filter (ext: all ? "${ext}") extensions));
            });

          phpDerivations = rec
          {
            default = phpDerivations.php81;

            php56 = {
              php = phps.php56;
              withExtensions = defaultExtensions ++ requiredExts;
              withoutExtensions = [ "sodium" "pcov" ];
            };

            php70 = {
              php = phps.php70;
              withExtensions = defaultExtensions ++ requiredExts;
              withoutExtensions = [ "sodium" ];
            };

            php71 = {
              php = phps.php71;
              withExtensions = defaultExtensions ++ requiredExts;
              withoutExtensions = [ "sodium" ];
            };

            php72 = {
              php = phps.php72;
              withExtensions = defaultExtensions ++ requiredExts;
            };

            php73 = {
              php = phps.php73;
              withExtensions = defaultExtensions ++ requiredExts;
            };

            php74 = {
              php = pkgs.php74;
              withExtensions = defaultExtensions ++ requiredExts;
            };

            php80 = {
              php = pkgs.php80;
              withExtensions = defaultExtensions ++ requiredExts;
            };

            php81 = {
              php = pkgs.php81;
              withExtensions = defaultExtensions ++ requiredExts;
            };
          };

          # Build PHP NTS.
          phpDerivationsWithNts = phpDerivations // lib.mapAttrs' (name: php:
            lib.nameValuePair
              (name + "-nts")
              (
                php // {
                  flags = {
                    apxs2Support = false;
                    ztsSupport = false;
                  };
                }
              )
            ) phpDerivations;
        in
        {
          # In use for "nix shell"
          packages = builtins.mapAttrs
            (name: phpConfig: pkgs.buildEnv {
              inherit name;
              paths = [
                (makePhp {
                  php = phpConfig.php;
                  flags = phpConfig.flags or {};
                  withExtensions = phpConfig.withExtensions;
                  withoutExtensions = phpConfig.withoutExtensions or [];
                })
              ];
            })
            phpDerivationsWithNts //
            lib.mapAttrs' (name: phpConfig:
              let
                pname = "env-" + name;
              in
              lib.nameValuePair
                (pname)
                (
                  makePhpEnv pname (makePhp {
                    php = phpConfig.php;
                    flags = phpConfig.flags or {};
                    withExtensions = phpConfig.withExtensions;
                    withoutExtensions = phpConfig.withoutExtensions or [];
                  })
                )
              ) phpDerivationsWithNts;

          # In use for "nix develop"
          devShells = builtins.mapAttrs
            (name: phpConfig: pkgs.mkShellNoCC {
              inherit name;
              buildInputs = [
                (makePhp {
                  php = phpConfig.php;
                  flags = phpConfig.flags or {};
                  withExtensions = phpConfig.withExtensions ++ requiredDevExts;
                  withoutExtensions = phpConfig.withoutExtensions or [];
                })
              ];
            })
            phpDerivationsWithNts //
            lib.mapAttrs' (name: phpConfig:
              let
                phpEnv = makePhpEnv name (makePhp {
                  php = phpConfig.php;
                  flags = phpConfig.flags or {};
                  withExtensions = phpConfig.withExtensions ++ requiredDevExts;
                  withoutExtensions = phpConfig.withoutExtensions or [];
                });
              in
                let
                  pname = "env-" + name;
                in
                lib.nameValuePair
                  (pname)
                  (
                    pkgs.mkShellNoCC {
                      name = pname;
                      buildInputs = [ phpEnv ];
                    }
                  )
                )
            phpDerivationsWithNts;
        }
      );
}
