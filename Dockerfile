FROM php:5.6.38-fpm-alpine3.8 AS ScratchENV

LABEL maintainer="yanguang.wang@nexusguard.com"

RUN apk add --no-cache $PHPIZE_DEPS \
        && wget http://mirror.bit.edu.cn/apache/zookeeper/zookeeper-3.4.12/zookeeper-3.4.12.tar.gz \
        && tar -zxvf zookeeper-3.4.12.tar.gz \
        && cd zookeeper-3.4.12/src/c \ 
        && ./configure \
        && make && make install \
        && pecl install zookeeper 

FROM php:5.6.38-fpm-alpine3.8 AS RuntimeENV

LABEL maintainer="yanguang.wang@nexusguard.com"

COPY --from=ScratchENV /usr/local/lib/libzookeeper_mt.so.2.0.0 /usr/local/lib/libzookeeper_mt.so.2.0.0
COPY --from=ScratchENV /usr/local/lib/php/extensions/no-debug-non-zts-20131226/zookeeper.so /usr/local/lib/php/extensions/no-debug-non-zts-20131226/zookeeper.so
RUN ln -s /usr/local/lib/libzookeeper_mt.so.2.0.0 /usr/local/lib/libzookeeper_mt.so.2 \
        && ln -s /usr/local/lib/libzookeeper_mt.so.2.0.0 /usr/local/lib/libzookeeper_mt.so \
        && echo "extension=zookeeper.so" > /usr/local/etc/php/conf.d/zookeeper.ini

RUN apk add --no-cache --update \
            php5-wddx \
            php5-xmlrpc \
            php5-xsl \
            php5-bz2 \
            php5-gd \ 
            php5-gettext \
            php5-gmp \
            php5-soap \
            libmcrypt-dev \
            libmcrypt \
            openssl-dev \
        && apk add --no-cache --virtual .phpize_deps \
            $PHPIZE_DEPS \
            autoconf \
            libxml2-dev \
        && apk --update add --no-cache -X 'http://dl-cdn.alpinelinux.org/alpine/edge/main' libcrypto1.1 \
        && apk --update add --no-cache -X 'http://dl-cdn.alpinelinux.org/alpine/edge/main' libssl1.1 \
        && apk --update add --no-cache -X 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' gearman-dev \
        && apk --update add --no-cache -X 'http://dl-cdn.alpinelinux.org/alpine/edge/community' libzip-dev \
        && apk --update add --no-cache -X 'http://dl-cdn.alpinelinux.org/alpine/edge/community' librdkafka-dev \
        && docker-php-ext-enable /usr/lib/php5/modules/wddx.so \ 
            /usr/lib/php5/modules/xmlrpc.so \ 
            /usr/lib/php5/modules/xsl.so \ 
            /usr/lib/php5/modules/bz2.so \ 
            /usr/lib/php5/modules/gd.so \ 
            /usr/lib/php5/modules/gettext.so \ 
            /usr/lib/php5/modules/gmp.so \
        && docker-php-ext-configure \
            mcrypt \
        && docker-php-ext-install \
            mcrypt \
            soap \
            bcmath \
            calendar \
            dba \
            exif \
            mysql \
            mysqli \
            pcntl \
            pdo_mysql \
            shmop \
            sockets \
            sysvmsg \
            sysvsem \
            sysvshm \
        && pecl install \
            redis-4.0.1 \
            igbinary \
            mongo \
            gearman \
            zip \
            rdkafka \
        && docker-php-ext-enable \
            redis \
            igbinary \
            mongo \
            gearman \
            zip \
            rdkafka \
        && apk del --purge .phpize_deps
