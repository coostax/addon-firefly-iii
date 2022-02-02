ARG BUILD_FROM

FROM $BUILD_FROM

# Default ENV
ENV \
    LANG="C.UTF-8" \
    DEBIAN_FRONTEND="noninteractive" \
    CURL_CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt" \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_CMD_WAIT_FOR_SERVICES=1

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Version
ARG \
    BASHIO_VERSION \
    TEMPIO_VERSION \
    S6_OVERLAY_VERSION \
    FIREFLY_VERSION

# Base system
WORKDIR /usr/src
ARG BUILD_ARCH

RUN \
    set -x \
    && apt-get update && apt-get install -y --no-install-recommends \
        bash \
        jq \
        tzdata \
        locales \
        git \
        mariadb-client \
        nginx \
        software-properties-common \
        unzip \
        curl \
        ca-certificates \
    #common debian docker base instructions
    && mkdir -p /usr/share/man/man1 \
    \
    && if [ "${BUILD_ARCH}" = "armv7" ]; then \
            export S6_ARCH="arm"; \
        elif [ "${BUILD_ARCH}" = "i386" ]; then \
            export S6_ARCH="x86"; \
        else \
            export S6_ARCH="${BUILD_ARCH}"; \
        fi \
    \
    && curl -L -f -s "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}.tar.gz" \
        | tar zxvf - -C / \
    && mkdir -p /etc/fix-attrs.d \
    && mkdir -p /etc/services.d \
    \
    && curl -L -f -s -o /usr/bin/tempio \
        "https://github.com/home-assistant/tempio/releases/download/${TEMPIO_VERSION}/tempio_${BUILD_ARCH}" \
    && chmod a+x /usr/bin/tempio \
    \
    && mkdir -p /usr/src/bashio \
    && curl -L -f -s "https://github.com/hassio-addons/bashio/archive/v${BASHIO_VERSION}.tar.gz" \
        | tar -xzf - --strip 1 -C /usr/src/bashio \
    && mv /usr/src/bashio/lib /usr/lib/bashio \
    && rm -f /usr/bin/bashio \
    && ln -s /usr/lib/bashio/bashio /usr/bin/bashio \
    #Install and config PHP 8.0
    && curl -J -L -o /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && echo "deb https://packages.sury.org/php/ buster main" > /etc/apt/sources.list.d/php.list \
    && apt-get update \
    && apt-get install  -y --no-install-recommends \
        php8.0-bcmath \
        php8.0-curl \
        php8.0-cli \
        php8.0-common \
        php8.0-fpm \
        php8.0-gd \
        php8.0-intl \
        php8.0-ldap \
        php8.0-mbstring \
        php8.0-mysql \
        php8.0-opcache \
        php8.0-readline \
        php8.0-sqlite3 \
        php8.0-xml \
        php8.0-zip \
        php8.0 \
    \
    #Install composer
    && curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /tmp/composer && chmod +x /tmp/composer \
    && curl -J -L -o /tmp/firefly.tar.gz \
        https://github.com/firefly-iii/firefly-iii/archive/${FIREFLY_VERSION}.tar.gz \
    &&  mkdir -p /var/www/firefly \
    && tar zxf /tmp/firefly.tar.gz -C \
        /var/www/firefly --strip-components=1 \
    && printf "vi_VN.UTF-8 UTF-8\nfi_FI.UTF-8 UTF-8\nsv_SE.UTF-8 UTF-8\nel_GR.UTF-8 UTF-8\nhu_HU.UTF-8 UTF-8\nro_RO.UTF-8 UTF-8\nnb_NO.UTF-8 UTF-8\nde_DE.UTF-8 UTF-8\ncs_CZ.UTF-8 UTF-8\nen_US.UTF-8 UTF-8\nes_ES.UTF-8 UTF-8\nfr_FR.UTF-8 UTF-8\nid_ID.UTF-8 UTF-8\nit_IT.UTF-8 UTF-8\nnl_NL.UTF-8 UTF-8\npl_PL.UTF-8 UTF-8\npt_PT.UTF-8 UTF-8\nru_RU.UTF-8 UTF-8\ntr_TR.UTF-8 UTF-8\nzh_TW.UTF-8 UTF-8\nzh_CN.UTF-8 UTF-8\n\n" > /etc/locale.gen \
    && locale-gen \
    && cd /var/www/firefly \
    && /tmp/composer install --prefer-dist --no-dev --no-scripts --no-suggest \
    && apt-get purge -y --auto-remove \
        git \
        software-properties-common \
        unzip \
    \
    && rm -f /tmp/composer \
    && apt-get clean \
    && find /var/www/firefly -type f -name "*.md" -depth -exec rm -f {} \; \
    && rm -f -r \
        /tmp/* \
        /etc/nginx \
        /var/{cache,log}/* \
        /var/lib/apt/lists/* \
        /usr/src/* \
        /var/www/firefly/Docker* \
        /var/www/firefly/docker* \
        /var/www/firefly/phpunit* \
        \
    && mkdir -p /var/log/nginx \
    && touch /var/log/nginx/error.log

# S6-Overlay
WORKDIR /

# Copy root filesystem
COPY rootfs /

ENTRYPOINT ["/init"]
