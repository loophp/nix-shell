{ pkgs ? (import <nixpkgs> {}), ... }:

(import ../common.nix) {
    inherit pkgs;

    phpPkg = pkgs.php80;

    phpIni = ''
        max_execution_time = 0
        xdebug.mode=debug
        memory_limit=-1
    '';

    phpExtensions = { all, ... }: with all; [
        # Mandatory
        filter
        iconv
        ctype
        redis
        tokenizer
        simplexml

        # Recommendations
        dom
        posix
        intl
        opcache

        # Optional
        pcov
        pdo_sqlite
        pdo_mysql
        pdo_pgsql

        openssl
        calendar
        soap
        mbstring
        exif
        fileinfo
        gd
        curl
        zip
        xmlwriter
        xdebug
    ];
}
