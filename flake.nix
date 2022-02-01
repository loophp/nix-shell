{
  description = "PHP/Composer/SymfonyCLi/GithubCLi/git/sqlite/make/docker-compose";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    phps.url = "github:fossar/nix-phps";
  };

  outputs = { self, flake-utils, nixpkgs, phps }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
        };

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

        defaultEmptyPhpExtensions = all: with all; [ ];

        defaultDebugPhpExtensions = all: with all; [
          pcov
          xdebug
        ];

        phpIniFile = "${builtins.getEnv "PWD"}/.php.ini";
        extraConfig = if builtins.pathExists "${phpIniFile}" then builtins.readFile "${phpIniFile}" else "";
        php = phps.packages.${system};
        phpExtensions = default: without: { all, ... }: builtins.filter (x: !builtins.elem x (without all)) (default all);
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

        derivations = rec
        {
          default = (php.php81.override { }).buildEnv {
            # TODO: Make a function which deals with strings instead of derivations.
            # TODO: Such as: makePhpExtension ["a" "b" "c"] ["x" "y" "z"]
            # TODO: The first argument is the list of extentions to include
            # TODO: The second argument is the list of extensions to exclude
            extensions = phpExtensions defaultPhpExtensions defaultEmptyPhpExtensions;
            inherit extraConfig;
          };

          default-nts = (php.php81.override { apxs2Support = false; }).buildEnv {
            extensions = phpExtensions defaultPhpExtensions defaultEmptyPhpExtensions;
            inherit extraConfig;
          };

          php56 = (php.php56.override { }).buildEnv {
            extensions = phpExtensions defaultPhpExtensions defaultEmptyPhpExtensions;
            inherit extraConfig;
          };

          php56-nodebug = (php.php56.override { }).buildEnv {
            extensions = phpExtensions defaultPhpExtensions defaultDebugPhpExtensions;
            inherit extraConfig;
          };

          php56-nts = (php.php56.override { apxs2Support = false; }).buildEnv {
            extensions = phpExtensions defaultPhpExtensions defaultEmptyPhpExtensions;
            inherit extraConfig;
          };

          php56-nts-nodebug = (php.php56.override { apxs2Support = false; }).buildEnv {
            extensions = phpExtensions defaultPhpExtensions defaultDebugPhpExtensions;
            inherit extraConfig;
          };

          php70 = (php.php70.override { }).buildEnv {
            extensions = phpExtensions defaultPhpExtensions defaultEmptyPhpExtensions;
            inherit extraConfig;
          };

          php70-nts = (php.php70.override { apxs2Support = false; }).buildEnv {
            extensions = phpExtensions defaultPhpExtensions defaultEmptyPhpExtensions;
            inherit extraConfig;
          };

          php71 = (php.php71.override { }).buildEnv {
            extensions = phpExtensions defaultPhpExtensions defaultEmptyPhpExtensions;
            inherit extraConfig;
          };

          php71-nodebug = (php.php71.override { }).buildEnv {
            extensions = phpExtensions defaultPhpExtensions defaultDebugPhpExtensions;
            inherit extraConfig;
          };

          php71-nts = (php.php71.override { apxs2Support = false; }).buildEnv {
            extensions = phpExtensions defaultPhpExtensions defaultEmptyPhpExtensions;
            inherit extraConfig;
          };

          php71-nts-nodebug = (php.php71.override { apxs2Support = false; }).buildEnv {
            extensions = phpExtensions defaultPhpExtensions defaultDebugPhpExtensions;
            inherit extraConfig;
          };

          php72 = (php.php72.override { }).buildEnv {
            extensions = phpExtensions defaultPhpExtensions defaultEmptyPhpExtensions;
            inherit extraConfig;
          };

          php72-nodebug = (php.php72.override { }).buildEnv {
            extensions = phpExtensions defaultPhpExtensions defaultDebugPhpExtensions;
            inherit extraConfig;
          };

          php72-nts = (php.php72.override { apxs2Support = false; }).buildEnv {
            extensions = phpExtensions defaultPhpExtensions defaultEmptyPhpExtensions;
            inherit extraConfig;
          };

          php72-nts-nodebug = (php.php72.override { apxs2Support = false; }).buildEnv {
            extensions = phpExtensions defaultPhpExtensions defaultDebugPhpExtensions;
            inherit extraConfig;
          };

          php73 = (php.php73.override { }).buildEnv {
            extensions = phpExtensions defaultPhpExtensions defaultEmptyPhpExtensions;
            inherit extraConfig;
          };

          php73-nodebug = (php.php73.override { }).buildEnv {
            extensions = phpExtensions defaultPhpExtensions defaultDebugPhpExtensions;
            inherit extraConfig;
          };

          php73-nts = (php.php73.override { apxs2Support = false; }).buildEnv {
            extensions = phpExtensions defaultPhpExtensions defaultEmptyPhpExtensions;
            inherit extraConfig;
          };

          php73-nts-nodebug = (php.php73.override { apxs2Support = false; }).buildEnv {
            extensions = phpExtensions defaultPhpExtensions defaultDebugPhpExtensions;
            inherit extraConfig;
          };

          php74 = (php.php74.override { }).buildEnv {
            extensions = phpExtensions defaultPhpExtensions defaultEmptyPhpExtensions;
            inherit extraConfig;
          };

          php74-nts = (php.php74.override { apxs2Support = false; }).buildEnv {
            extensions = phpExtensions defaultPhpExtensions defaultEmptyPhpExtensions;
            inherit extraConfig;
          };

          php74-nodebug = (php.php74.override { apxs2Support = true; }).buildEnv {
            extensions = phpExtensions defaultPhpExtensions defaultDebugPhpExtensions;
            inherit extraConfig;
          };

          php74-nts-nodebug = (php.php74.override { apxs2Support = false; }).buildEnv {
            extensions = phpExtensions defaultPhpExtensions defaultDebugPhpExtensions;
            inherit extraConfig;
          };

          php80 = (php.php80.override { }).buildEnv {
            extensions = phpExtensions defaultPhpExtensions defaultEmptyPhpExtensions;
            inherit extraConfig;
          };

          php80-nts = (php.php80.override { apxs2Support = false; }).buildEnv {
            extensions = phpExtensions defaultPhpExtensions defaultEmptyPhpExtensions;
            inherit extraConfig;
          };

          php80-nodebug = (php.php80.override { apxs2Support = true; }).buildEnv {
            extensions = phpExtensions defaultPhpExtensions defaultDebugPhpExtensions;
            inherit extraConfig;
          };

          php80-nts-nodebug = (php.php80.override { apxs2Support = false; }).buildEnv {
            extensions = phpExtensions defaultPhpExtensions defaultDebugPhpExtensions;
            inherit extraConfig;
          };

          php81 = (php.php81.override { }).buildEnv {
            extensions = phpExtensions defaultPhpExtensions defaultEmptyPhpExtensions;
            inherit extraConfig;
          };

          php81-nts = (php.php81.override { apxs2Support = false; }).buildEnv {
            extensions = phpExtensions defaultPhpExtensions defaultEmptyPhpExtensions;
            inherit extraConfig;
          };

          php81-nodebug = (php.php81.override { apxs2Support = true; }).buildEnv {
            extensions = phpExtensions defaultPhpExtensions defaultDebugPhpExtensions;
            inherit extraConfig;
          };

          php81-nts-nodebug = (php.php81.override { apxs2Support = false; }).buildEnv {
            extensions = phpExtensions defaultPhpExtensions defaultDebugPhpExtensions;
            inherit extraConfig;
          };

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
