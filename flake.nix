{
  description = "PHP/Composer/SymfonyCLi/GithubCLi/git/sqlite/make/docker-compose";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
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

        default = import ./resources/dev/common.nix {
          inherit pkgs;
          phps = phps.packages.${system};
          version = "php81";
          phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x [ ]) (default all);
          apxs2Support = true;
        };

        default-nts = import ./resources/dev/common.nix {
          inherit pkgs;
          phps = phps.packages.${system};
          version = "php81";
          phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x [ ]) (default all);
          apxs2Support = false;
        };

        php56 = import ./resources/dev/common.nix {
          inherit pkgs;
          phps = phps.packages.${system};
          version = "php56";
          phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x [ ]) (default all);
          apxs2Support = true;
        };

        php56-nts = import ./resources/dev/common.nix {
          inherit pkgs;
          phps = phps.packages.${system};
          version = "php56";
          phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x [ ]) (default all);
          apxs2Support = false;
        };

        php70 = import ./resources/dev/common.nix {
          inherit pkgs;
          phps = phps.packages.${system};
          version = "php70";
          phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x [ ]) (default all);
          apxs2Support = true;
        };

        php70-nts = import ./resources/dev/common.nix {
          inherit pkgs;
          phps = phps.packages.${system};
          version = "php70";
          phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x [ ]) (default all);
          apxs2Support = false;
        };

        php71 = import ./resources/dev/common.nix {
          inherit pkgs;
          phps = phps.packages.${system};
          version = "php71";
          phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x [ ]) (default all);
          apxs2Support = true;
        };

        php71-nts = import ./resources/dev/common.nix {
          inherit pkgs;
          phps = phps.packages.${system};
          version = "php71";
          phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x [ ]) (default all);
          apxs2Support = false;
        };

        php72 = import ./resources/dev/common.nix {
          inherit pkgs;
          phps = phps.packages.${system};
          version = "php72";
          phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x [ ]) (default all);
          apxs2Support = true;
        };

        php72-nts = import ./resources/dev/common.nix {
          inherit pkgs;
          phps = phps.packages.${system};
          version = "php72";
          phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x [ ]) (default all);
          apxs2Support = false;
        };

        php73 = import ./resources/dev/common.nix {
          inherit pkgs;
          phps = phps.packages.${system};
          version = "php73";
          phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x [ ]) (default all);
          apxs2Support = true;
        };

        php73-nts = import ./resources/dev/common.nix {
          inherit pkgs;
          phps = phps.packages.${system};
          version = "php73";
          phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x [ ]) (default all);
          apxs2Support = false;
        };

        php74 = import ./resources/dev/common.nix {
          inherit pkgs;
          phps = phps.packages.${system};
          version = "php74";
          phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x [ ]) (default all);
          apxs2Support = true;
        };

        php74-nts = import ./resources/dev/common.nix {
          inherit pkgs;
          phps = phps.packages.${system};
          version = "php74";
          phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x [ ]) (default all);
          apxs2Support = false;
        };

        php74-nodebug = import ./resources/dev/common.nix {
          inherit pkgs;
          phps = phps.packages.${system};
          version = "php74";
          phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x [ all.xdebug all.pcov ]) (default all);
          apxs2Support = true;
        };

        php74-nts-nodebug = import ./resources/dev/common.nix {
          inherit pkgs;
          phps = phps.packages.${system};
          version = "php74";
          phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x [ all.xdebug all.pcov ]) (default all);
          apxs2Support = false;
        };

        php80 = import ./resources/dev/common.nix {
          inherit pkgs;
          phps = phps.packages.${system};
          version = "php80";
          phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x [ ]) (default all);
          apxs2Support = true;
        };

        php80-nts = import ./resources/dev/common.nix {
          inherit pkgs;
          phps = phps.packages.${system};
          version = "php80";
          phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x [ ]) (default all);
          apxs2Support = false;
        };

        php80-nodebug = import ./resources/dev/common.nix {
          inherit pkgs;
          phps = phps.packages.${system};
          version = "php80";
          phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x [ all.xdebug all.pcov ]) (default all);
          apxs2Support = true;
        };

        php80-nts-nodebug = import ./resources/dev/common.nix {
          inherit pkgs;
          phps = phps.packages.${system};
          version = "php80";
          phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x [ all.xdebug all.pcov ]) (default all);
          apxs2Support = false;
        };

        php81 = import ./resources/dev/common.nix {
          inherit pkgs;
          phps = phps.packages.${system};
          version = "php81";
          phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x [ ]) (default all);
          apxs2Support = true;
        };

        php81-nts = import ./resources/dev/common.nix {
          inherit pkgs;
          phps = phps.packages.${system};
          version = "php81";
          phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x [ ]) (default all);
          apxs2Support = false;
        };

        php81-nodebug = import ./resources/dev/common.nix {
          inherit pkgs;
          phps = phps.packages.${system};
          version = "php81";
          phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x [ all.xdebug all.pcov ]) (default all);
          apxs2Support = true;
        };

        php81-nts-nodebug = import ./resources/dev/common.nix {
          inherit pkgs;
          phps = phps.packages.${system};
          version = "php81";
          phpExtensions = default: { all, ... }: builtins.filter (x: !builtins.elem x [ all.xdebug all.pcov ]) (default all);
          apxs2Support = false;
        };
      in
      {
        devShells = {
          inherit default;
          inherit default-nts;
          inherit php56;
          inherit php56-nts;
          inherit php70;
          inherit php70-nts;
          inherit php71;
          inherit php71-nts;
          inherit php72;
          inherit php72-nts;
          inherit php73;
          inherit php73-nts;
          inherit php74;
          inherit php74-nts;
          inherit php74-nodebug;
          inherit php74-nts-nodebug;
          inherit php80;
          inherit php80-nodebug;
          inherit php80-nts;
          inherit php80-nts-nodebug;
          inherit php81;
          inherit php81-nodebug;
          inherit php81-nts;
          inherit php81-nts-nodebug;
        };

        packages = (pkgs) default default-nts php56 php56-nts php70 php70-nts php71 php71-nts php72 php72-nts php73 php73-nts php74 php74-nts php74-nodebug php74-nts-nodebug php80 php80-nodebug php80-nts php80-nts-nodebug php81 php81-nodebug php81-nts php81-nts-nodebug;
      }
    );
}
