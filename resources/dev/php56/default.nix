(import ../common.nix) {
    version = "php56";

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
        tokenizer
        simplexml

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
        pdo_sqlite
        pdo_mysql
        pdo_pgsql
        soap
        xmlreader
        xmlwriter
        zip
        zlib
    ];
}
