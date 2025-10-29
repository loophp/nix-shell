[![GitHub stars][github stars]][1]
[![Donate!][donate github]][5]

# Nix shell

![Tutorial](./docs/readme.gif "Tutorial")

## Description

This package provides a `Nix flake` ready to use
for PHP development, using the [`Nix` package manager][50]
which can be installed on (_almost_) any operating system.

Each available environment provides the following tools:

- Composer,
- Symfony CLI,
- SQLite

Available stable PHP versions from `5.6` to `8.4`.

To list the available PHP versions, run:

```shell
nix flake show github:loophp/nix-shell
```

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

To load extensions from the `require` and `required-dev` sections, using the flag
`--impure` is required. Example:

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

This project also provides a basic template for PHP projects, to use it, run:

```shell
nix flake init --template github:loophp/nix-shell#basic
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

Since the 14th of November 2022, PHP is in `NTS` mode by default (see
[#154774](https://github.com/NixOS/nixpkgs/issues/154774)).

To list the available PHP versions and environments, run:

```shell
nix flake show github:loophp/nix-shell
```

### In another flake

<details>

<summary>Step 1</summary>

Import the input:

```nix
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    phps.url = "github:loophp/nix-shell";
  };
```

</details>

<details>

<summary>Step 2</summary>

Import the overlay:

```nix
pkgs = import inputs.nixpkgs {
    inherit system;
    overlays = [
        inputs.phps.overlays.default
    ];
};
```

</details>

<details>

<summary>Step 3</summary>

Use the packages:

```nix
    # PHP 8.1 environment
    pkgs.env-php81
```

</details>

To create your own version of PHP, use the available API function `buildPhpFromComposer`.

### With direnv

`direnv` is an extension for your shell. It augments existing shells with a new
feature that can load and unload environment variables depending on the current
directory. You can use it within Nix ([nix-direnv][nix direnv]) and load a
development environment just by changing directory.

Edit the file `.envrc` and add the following line:

```
use flake github:loophp/nix-shell#env-php-master-snapshot --impure
```

And it's done.

### Customize PHP

To customize the PHP configuration, you can do it like this:

```shell
nix shell github:loophp/nix-shell#php81
php -c /path/to/the/config.ini <<command>>
```

[Another option][doc .user.ini] would be to create a `.user.ini` file within
your current working directory before running the PHP environment, as such:

```ini
max_execution_time = 0
memory_limit = 2048M
```

Then run:

```shell
nix shell github:loophp/nix-shell#php82 --impure
```

The `--impure` flag is important to make sure that your custom
`.user.ini` file is correctly taken in account.

## Contributing

Feel free to contribute by sending pull requests. We are a
usually very responsive team and we will help you going
through your pull request from the beginning to the end.

For some reasons, if you can't contribute to the code and are
willing to help, sponsoring is a good, sound, and safe way
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
