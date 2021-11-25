[![Latest Stable Version][latest stable version]][1]
 [![GitHub stars][github stars]][1]
 [![Total Downloads][total downloads]][1]
 [![License][license]][1]
 [![Donate!][donate github]][5]
 [![Donate!][donate paypal]][6]

# Nix shell

## Description

This is a totally experimental package to centralize
[development environment][46] files tailored for PHP development.

This package provides a Nix `flakes` ready to use
for PHP development.

Each available environment provides the following tools:

* PHP with extensions, `xdebug` and `pcov`
* Custom `php.ini`
* Composer
* docker-compose
* Git
* Github CLi
* Symfony CLi
* GNU Make

## Usage

```shell
nix develop github:loophp/nix-shell#php80
```

Available PHP versions are:

* `php56`
* `php70`
* `php71`
* `php72`
* `php73`
* `php74`
* `php74-nodebug`
* `php80`
* `php80-nodebug`

### Customize PHP

To customize the PHP configuration, you can do it like this:

```shell
nix develop github:loophp/nix-shell#php80
php -c /path/to/the/config.ini <<command>>
```

Another option would be to create a `.php.ini` file within your
current working directory before running the PHP environment,
as such:

```ini
max_execution_time = 0
memory_limit = 2048M
```

Then run:


```shell
nix develop github:loophp/nix-shell#php80 --impure
```

The `--impure` flag is important to make sure that your custom
`.php.ini` file is correctly taken in account.

## Contributing

Feel free to contribute by sending Github pull requests. I'm quite responsive :-)

If you can't contribute to the code, you can also sponsor me on [Github][5] or
[Paypal][6].

## Thanks

* [Jan Tojnar][47] for assisting me into incorporating his [own package][48].

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
[6]: https://www.paypal.me/drupol
[43]: https://github.com/loophp/nix-shell/blob/master/CHANGELOG.md
[44]: https://github.com/loophp/nix-shell/commits/master
[45]: https://github.com/loophp/nix-shell/releases
[46]: https://nixos.org/guides/nix-pills/developing-with-nix-shell.html
[47]: https://github.com/jtojnar
[48]: https://github.com/fossar/nix-phps
