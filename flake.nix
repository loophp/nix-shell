{
  description = "PHP/Composer/SymfonyCLi/GithubCLi/git/sqlite/make";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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

              phpIniFile = "${builtins.getEnv "PWD"}/.php.ini";

              extensions = builtins.filter (x: !builtins.elem x withoutExtensions) (lib.unique (withExtensions ++ userExtensions));
            in
            ((php.override flags).buildEnv {
              extraConfig = extraConfig + "\n" + (if builtins.pathExists "${phpIniFile}" then builtins.readFile "${phpIniFile}" else "");
              extensions = { all, ... }: (map (ext: all."${ext}") (builtins.filter (ext: all ? "${ext}") extensions));
            });

          derivations = rec
          {
            default = derivations.php81;
            default-nts = derivations.php81-nts;

            php56 = makePhp {
              php = phps.php56;
              withExtensions = defaultExtensions;
              withoutExtensions = [ "sodium" "pcov" ];
            };

            php56-nts = makePhp {
              php = phps.php56;
              withExtensions = defaultExtensions;
              withoutExtensions = [ "sodium" "pcov" ];
              flags = {
                apxs2Support = false;
                ztsSupport = false;
              };
            };

            php70 = makePhp {
              php = phps.php70;
              withExtensions = defaultExtensions;
              withoutExtensions = [ "sodium" ];
            };

            php70-nts = makePhp {
              php = phps.php70;
              withExtensions = defaultExtensions;
              withoutExtensions = [ "sodium" ];
              flags = {
                apxs2Support = false;
                ztsSupport = false;
              };
            };

            php71 = makePhp {
              php = phps.php71;
              withExtensions = defaultExtensions;
              withoutExtensions = [ "sodium" ];
            };

            php71-nts = makePhp {
              php = phps.php71;
              withExtensions = defaultExtensions;
              withoutExtensions = [ "sodium" ];
              flags = {
                apxs2Support = false;
                ztsSupport = false;
              };
            };

            php72 = makePhp {
              php = phps.php72;
              withExtensions = defaultExtensions;
            };

            php72-nts = makePhp {
              php = phps.php72;
              withExtensions = defaultExtensions;
              flags = {
                apxs2Support = false;
                ztsSupport = false;
              };
            };

            php73 = makePhp {
              php = phps.php73;
              withExtensions = defaultExtensions;
            };

            php73-nts = makePhp {
              php = phps.php73;
              withExtensions = defaultExtensions;
              flags = {
                apxs2Support = false;
                ztsSupport = false;
              };
            };

            php74 = makePhp {
              php = phps.php74;
              withExtensions = defaultExtensions;
            };

            php74-nts = makePhp {
              php = phps.php74;
              withExtensions = defaultExtensions;
              flags = {
                apxs2Support = false;
                ztsSupport = false;
              };
            };

            php80 = makePhp {
              php = phps.php80;
              withExtensions = defaultExtensions;
           };

            php80-nts = makePhp {
              php = phps.php80;
              withExtensions = defaultExtensions;
              flags = {
                apxs2Support = false;
                ztsSupport = false;
              };
            };

            php81 = makePhp {
              php = phps.php81;
              withExtensions = defaultExtensions;
            };

            php81-nts = makePhp {
              php = phps.php81;
              withExtensions = defaultExtensions;
              flags = {
                apxs2Support = false;
                ztsSupport = false;
              };
            };

            env-default = makePhpEnv "env-php-default" derivations.php81;
            env-default-nts = makePhpEnv "env-php-nts" derivations.php81-nts;

            env-php56 = makePhpEnv "env-php56" php56;
            env-php70 = makePhpEnv "env-php70" php70;
            env-php71 = makePhpEnv "env-php71" php71;
            env-php72 = makePhpEnv "env-php72" php72;
            env-php73 = makePhpEnv "env-php73" php73;
            env-php74 = makePhpEnv "env-php74" php74;
            env-php80 = makePhpEnv "env-php80" php80;
            env-php81 = makePhpEnv "env-php81" php81;

            env-php56-nts = makePhpEnv "env-php56-nts" php56-nts;
            env-php70-nts = makePhpEnv "env-php70-nts" php70-nts;
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
