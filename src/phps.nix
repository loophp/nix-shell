{
  self,
  inputs,
  lib,
  ...
}: let
  matrix = let
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
  in [
    {
      extensions = extensions ++ ["json"];
      withoutExtensions = ["sodium" "pcov"];
      php = "php56";
    }
    {
      extensions = extensions ++ ["json"];
      withoutExtensions = ["sodium"];
      php = "php70";
    }
    {
      extensions = extensions ++ ["json"];
      withoutExtensions = ["sodium"];
      php = "php71";
    }
    {
      extensions = extensions ++ ["json"];
      withoutExtensions = [];
      php = "php72";
    }
    {
      extensions = extensions ++ ["json"];
      withoutExtensions = [];
      php = "php73";
    }
    {
      extensions = extensions ++ ["json"];
      withoutExtensions = [];
      php = "php74";
    }
    {
      inherit extensions;
      php = "php80";
    }
    {
      inherit extensions;
      php = "php81";
    }
    {
      inherit extensions;
      php = "php82";
    }
  ];

  makePhp = system: let
    # See if we can do this in a better way.
    pkgsWithNixPhps = import inputs.nixpkgs {
      overlays = [inputs.nix-phps.overlays.default];
      inherit system;
    };
  in
    {
      php,
      extensions ? [],
      withExtensions ? [],
      withoutExtensions ? [],
      extraConfig ? "",
      extraConfigFile ? "${builtins.getEnv "PWD"}/.user.ini",
      flags ? {},
    }: let
      withExtensionsFiltered =
        builtins.filter
        (x: !builtins.elem x withoutExtensions)
        (lib.unique extensions ++ withExtensions);

      phpDrv =
        if builtins.isString php
        then pkgsWithNixPhps."${php}"
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
    inherit makePhp matrix;
  };
}
