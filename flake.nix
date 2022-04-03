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

          makePhp =
            { php
            , withExtensions ? [ ]
            , withoutExtensions ? [ ]
            , extraConfig ? ""
            , flags ? { }
            }:
            let
              readJsonSectionFromFile = file: section: default:
                let
                  filepath = "${builtins.getEnv "PWD"}/${file}";
                  filecontent = if builtins.pathExists filepath then builtins.fromJSON (builtins.readFile filepath) else { };
                in
                  filecontent.${section} or default;

              # Get "require" section to extract extensions later
              require = readJsonSectionFromFile "composer.json" "require" { };
              # Copy keys into values
              composerRequiresKeys = map (p: lib.attrsets.mapAttrs' (k: v: lib.nameValuePair k k) p) [ require ];
              # Convert sets into lists
              composerRequiresMap = map (package: (map (key: builtins.getAttr key package) (builtins.attrNames package))) composerRequiresKeys;
              # Convert the set into a list, filter out values not starting with "ext-", get rid of the first 4 characters from the name
              userExtensions = map (x: builtins.substring 4 (builtins.stringLength x) x) (builtins.filter (x: (builtins.substring 0 4 x) == "ext-") (lib.flatten composerRequiresMap));

              phpIniFile = "${builtins.getEnv "PWD"}/.user.ini";

              extensions = builtins.filter (x: !builtins.elem x withoutExtensions) (lib.unique (withExtensions ++ userExtensions));
            in
            ((php.override flags).buildEnv {
              extraConfig = extraConfig + "\n" + (if builtins.pathExists "${phpIniFile}" then builtins.readFile "${phpIniFile}" else "");
              extensions = { all, ... }: (map (ext: all."${ext}") (builtins.filter (ext: all ? "${ext}") extensions));
            });

          phpDerivations = rec
          {
            default = derivations.php81;

            php56 = makePhp {
              php = phps.php56;
              withExtensions = defaultExtensions;
              withoutExtensions = [ "sodium" "pcov" ];
            };

            php70 = makePhp {
              php = phps.php70;
              withExtensions = defaultExtensions;
              withoutExtensions = [ "sodium" ];
            };

            php71 = makePhp {
              php = phps.php71;
              withExtensions = defaultExtensions;
              withoutExtensions = [ "sodium" ];
            };

            php72 = makePhp {
              php = phps.php72;
              withExtensions = defaultExtensions;
            };

            php73 = makePhp {
              php = phps.php73;
              withExtensions = defaultExtensions;
            };

            php74 = makePhp {
              php = phps.php74;
              withExtensions = defaultExtensions;
            };

            php80 = makePhp {
              php = phps.php80;
              withExtensions = defaultExtensions;
            };

            php81 = makePhp {
              php = phps.php81;
              withExtensions = defaultExtensions;
            };
          };

          # Build PHP NTS.
          phpDerivationsWithNts = phpDerivations // lib.mapAttrs' (name: php:
            lib.nameValuePair
              (name + "-nts")
              (
                let
                  flags = {
                    apxs2Support = false;
                    ztsSupport = false;
                  };
                in
                  (php.override flags)
              )
            ) phpDerivations;

          # Build PHP environments.
          derivations = phpDerivationsWithNts // lib.mapAttrs' (name: php:
            let
              pname = "env-" + name;
            in
            lib.nameValuePair
              (pname)
              (makePhpEnv pname php)
            ) phpDerivationsWithNts;
        in
        {
          # This is deprecated in Nix 2.7.0
          defaultPackage = derivations.default-nts;

          # This is deprecated in Nix 2.7.0
          devShell = pkgs.mkShellNoCC {
            name = derivations.default.name;
            buildInputs = [ derivations.default-nts ];
          };

          packages = derivations;

          devShells = builtins.mapAttrs
            (name: value: pkgs.mkShellNoCC {
              inherit name;
              buildInputs = [ value ];
            })
            derivations;
        }
      );
}
