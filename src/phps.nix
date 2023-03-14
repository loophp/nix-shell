{
  self,
  inputs,
  ...
}: let
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
    "sysvsem"
    "tokenizer"
    "xmlreader"
    "xmlwriter"
    "zip"
    "zlib"
  ];

  extensions =
    defaultExtensions
    ++ self.composer.getExtensionFromSection "require"
    ++ self.composer.getExtensionFromSection "require-dev";

  phpMatrix = rec
  {
    default = phpMatrix.php81;

    php56 = {
      extensions = extensions ++ ["json"];
      withoutExtensions = ["sodium" "pcov"];
      php = "php56";
    };

    php70 = {
      extensions = extensions ++ ["json"];
      withoutExtensions = ["sodium"];
      php = "php70";
    };

    php71 = {
      extensions = extensions ++ ["json"];
      withoutExtensions = ["sodium"];
      php = "php71";
    };

    php72 = {
      extensions = extensions ++ ["json"];
      withoutExtensions = [];
      php = "php72";
    };

    php73 = {
      extensions = extensions ++ ["json"];
      withoutExtensions = [];
      php = "php73";
    };

    php74 = {
      extensions = extensions ++ ["json"];
      withoutExtensions = [];
      php = "php74";
    };

    php80 = {
      inherit extensions;
      php = "php80";
    };

    php81 = {
      inherit extensions;
      php = "php81";
    };

    php82 = {
      inherit extensions;
      php = "php82";
    };
  };

  makePhp = pkgs: {
    php,
    extensions ? phpMatrix."${php}".extensions,
    withExtensions ? [],
    withoutExtensions ? (phpMatrix."${php}".withoutExtensions or []),
    extraConfig ? "",
    extraConfigFile ? "${builtins.getEnv "PWD"}/.user.ini",
    flags ? {},
  }: let
    withExtensionsFiltered =
      builtins.filter
      (x: !builtins.elem x withoutExtensions)
      (pkgs.lib.unique extensions ++ withExtensions);

    phpDrv =
      if builtins.isString php
      then pkgs."${php}"
      else php;
  in ((phpDrv.override flags).buildEnv {
    extraConfig =
      extraConfig
      + "\n"
      + (
        if builtins.pathExists "${extraConfigFile}"
        then builtins.readFile "${extraConfigFile}"
        else ""
      );
    extensions = {all, ...}: (
      # We remove "null" extensions (like json for php >= 8)
      # See: https://github.com/fossar/nix-phps/pull/122
      builtins.filter
      (ext: ext != null)
      (
        map
        (ext:
          if builtins.isString ext
          then all."${ext}"
          else ext)
        (
          builtins.filter
          (ext:
            if builtins.isString ext
            then all ? "${ext}"
            else ext)
          withExtensionsFiltered
        )
      )
    );
  });
in {
  flake.api = {
    matrix = phpMatrix // {default = phpMatrix.php81;};
    makePhp = makePhp;
  };
}
