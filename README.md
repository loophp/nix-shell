[![GitHub stars][github stars]][1]
[![Donate!][donate github]][5]

# Nix shell

![Tutorial](./docs/readme.gif "Tutorial")

## Description

This package provides a `Nix flake` ready to use
for PHP development, using the [`Nix` package manager][50]
which can be installed on (_almost_) any operating system.

Each available environment provides the following tools:

- Custom `php.ini` loading,
- Composer,
- Git,
- Github CLi,
- Symfony CLi,
- GNU Make.

Available PHP versions from `5.6` to `8.2`.

The PHP extensions to use are automatically inferred from the `composer.json`
file.

```json
...8<...

"require": {
  "ext-intl": "*",
},
"require-dev": {
  "ext-xdebug": "*",
  "ext-pcov": "*",
}

...>8...
```

To load extensions from `require` and `required-dev` sections, using the flag
`--impure` is required. Exemple:

```shell
nix shell github:loophp/nix-shell#php82 --impure
```

We use [Cachix](https://app.cachix.org/cache/nix-shell) to store binaries of the
built packages. Install it as described in its [docs](https://docs.cachix.org/)
and then add the cache using `cachix use nix-shell` if you want to avoid
building those PHP packages yourself.

```shell
cachix use nix-shell
```

## Usage

While being extremely stable for years, "[flake][nix flake]" is an upcoming
feature of the Nix package manager. In order to use it, you must explicitly
enable it, please check the documentation to enable it, this is currently an
opt-in option.

### In a shell

To work with PHP 8.1 only:

```shell
nix shell github:loophp/nix-shell#php81
```

or with PHP 8.1 and a couple of useful tools:

```shell
nix shell github:loophp/nix-shell#env-php81
```

PHP has `ZTS` enabled by default (see [#154774](https://github.com/NixOS/nixpkgs/issues/154774)),
feel free to use the `NTS` if needed, see the matrix below.

Available PHP versions and environments are:

- `php56`, `php56-nts`
- `env-php56`, `env-php56-nts`
- `php70`, `php70-nts`
- `env-php70`, `env-php70-nts`
- `php71`, `php71-nts`
- `env-php71`, `env-php71-nts`
- `php72`, `php72-nts`
- `env-php72`, `env-php72-nts`
- `php73`, `php73-nts`
- `env-php73`, `env-php73-nts`
- `php74`, `php74-nts`
- `env-php74`, `env-php74-nts`
- `php80`, `php80-nts`
- `env-php80`, `env-php80-nts`
- `php81`, `php81-nts`
- `env-php81`, `env-php81-nts`
- `php82`, `php82-nts`
- `env-php82`, `env-php82-nts`

This package also provide development environments with some tools:

- [Symfony cli](https://github.com/symfony-cli/symfony-cli)
- [Github cli](https://cli.github.com/)
- [sqlite](https://www.sqlite.org/)
- [git](https://git-scm.com/)
- [gnumake](https://www.gnu.org/software/make/)

In order to use them, use the prefix `env-`:

```shell
nix shell github:loophp/nix-shell#env-php81-nts
```

### In another flake

Add the `loophp-nix-shell` input:

```nix
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    loophp-nix-shell.url = "github:loophp/nix-shell";
  };
```

Then to build the `pkgs` variable by using the provided default overlay:

```nix
pkgs = import nixpkgs {
  inherit system;
  overlays = [
    loophp-nix-shell.overlays.default
  ];
  config = {
    allowUnfreePredicate = (pkg: true);
  };
};
```

Each PHP derivation will be available in `pkgs.loophp-nix-shell.matrix`.

You may also use the functions to build your own custom version of PHP in your
own flake:

```nix
{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-shell.url = "github:loophp/nix-shell";
  };

  outputs = { self, nixpkgs, flake-utils, nix-shell }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              phps.overlays.default
            ];
            config = {
              allowUnfreePredicate = (pkg: true);
            };
          };

          php = (pkgs.loophp-nix-shell.makePhp pkgs {
            php = "php81";
            withExtensions = [ "pcov" "xdebug" ];
            withoutExtensions = [ "sodium" ];
            extraConfig = ''
              memory_limit=-1
            '';
            flags = {
              apxs2Support = false;
              ztsSupport = false;
            };
          });
        in
        {
          devShells = {
            default = pkgs.mkShellNoCC {
              name = "PHP project";

              buildInputs = [
                php
                php.packages.composer
                pkgs.mailhog
              ];
            };
          };
        }
      );
}
```

### With direnv

`direnv` is an extension for your shell. It augments existing shells with a new
feature that can load and unload environment variables depending on the current
directory. You can use it within Nix ([nix-direnv][nix direnv]) and load a
development environment just by changing directory.

Edit the file `.envrc` and add the line:

```
use flake github:loophp/nix-shell#env-php81-nts --impure
```

And it's done !

### Customize PHP

To customize the PHP configuration, you can do it like this:

```shell
nix shell github:loophp/nix-shell#php81
php -c /path/to/the/config.ini <<command>>
```

[Another option][doc .user.ini] would be to create a `.user.ini` file within your
current working directory before running the PHP environment,
as such:

```ini
max_execution_time = 0
memory_limit = 2048M
```

Then run:

```shell
nix shell github:loophp/nix-shell#php81 --impure
```

The `--impure` flag is important to make sure that your custom
`.user.ini` file is correctly taken in account.

## Contributing

Feel free to contribute by sending pull requests. We are a
usually very responsive team and we will help you going
through your pull request from the beginning to the end.

For some reasons, if you can't contribute to the code and
willing to help, sponsoring is a good, sound and safe way
to show us some gratitude for the hours we invested in this
package.

Sponsor me on [Github][5] and/or any of [the contributors][6].

## Thanks

- [Jan Tojnar][47] for assisting me into incorporating his [own package][48].
- [Aaron Anderse][52] for improving the code and giving some tips.

## Changelog

See [CHANGELOG.md][43] for a changelog based on [git commits][44].

For more detailed changelogs, please check [the release changelogs][45].

[1]: https://packagist.org/packages/loophp/nix-shell
[latest stable version]: https://img.shields.io/packagist/v/loophp/nix-shell.svg?style=flat-square
[github stars]: https://img.shields.io/github/stars/loophp/nix-shell.svg?style=flat-square
[total downloads]: https://img.shields.io/packagist/dt/loophp/nix-shell.svg?style=flat-square
[github workflow status]: https://img.shields.io/github/workflow/status/loophp/nix-shell/Unit%20tests?style=flat-square
[code quality]: https://img.shields.io/scrutinizer/quality/g/loophp/nix-shell/master.svg?style=flat-square
[3]: https://scrutinizer-ci.com/g/loophp/nix-shell/?branch=master
[type coverage]: https://img.shields.io/badge/dynamic/json?style=flat-square&color=color&label=Type%20coverage&query=message&url=https%3A%2F%2Fshepherd.dev%2Fgithub%2Floophp%2Fcollection%2Fcoverage
[4]: https://shepherd.dev/github/loophp/nix-shell
[code coverage]: https://img.shields.io/scrutinizer/coverage/g/loophp/nix-shell/master.svg?style=flat-square
[license]: https://img.shields.io/packagist/l/loophp/nix-shell.svg?style=flat-square
[donate github]: https://img.shields.io/badge/Sponsor-Github-brightgreen.svg?style=flat-square
[donate paypal]: https://img.shields.io/badge/Sponsor-Paypal-brightgreen.svg?style=flat-square
[34]: https://github.com/loophp/nix-shell/issues
[2]: https://github.com/loophp/nix-shell/actions
[35]: http://www.phpspec.net/
[36]: https://github.com/phpro/grumphp
[37]: https://github.com/infection/infection
[38]: https://github.com/phpstan/phpstan
[39]: https://github.com/vimeo/psalm
[5]: https://github.com/sponsors/drupol
[6]: https://github.com/loophp/nix-shell/graphs/contributors
[43]: https://github.com/loophp/nix-shell/blob/master/CHANGELOG.md
[44]: https://github.com/loophp/nix-shell/commits/master
[45]: https://github.com/loophp/nix-shell/releases
[46]: https://nixos.org/guides/nix-pills/developing-with-nix-shell.html
[47]: https://github.com/jtojnar
[48]: https://github.com/fossar/nix-phps
[50]: https://nixos.org/download.html
[52]: https://github.com/aanderse
[doc .user.ini]: https://www.php.net/manual/en/configuration.file.per-user.php
[nix flake]: https://nixos.wiki/wiki/Flakes
[nix direnv]: https://github.com/nix-community/nix-direnv
