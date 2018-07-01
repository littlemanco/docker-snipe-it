FROM quay.io/littlemanco/apache-php:7.1-latest

## Set some configuration for Laravel
ENV LOG_CHANNEL="errorlog"

VOLUME "/var/lib/snipeit/keys"
VOLUME "/var/lib/snipeit/data/private_uploads"
VOLUME "/var/lib/snipeit/data/uploads"
VOLUME "/var/lib/snipeit/dumps"

## The version of the upstream snipe project
## See https://github.com/snipe/snipe-it/releases
RUN export SNIPE_VERSION="4.4.1" && \
    ##
    ## The URL to fetch the release from
    ##
    export SNIPE_RELEASE_URL="https://github.com/snipe/snipe-it/archive/v${SNIPE_VERSION}.tar.gz" && \
    export WORKDIR=$(mktemp -d) && \
    export APP_DIR="/var/www/snipe" && \
    export APP_DATA_DIR="/var/lib/snipeit" && \
    ## 
    ## Build Dependencies
    ##
    export BUILD_DEPENDENCIES="composer" && \
    export RUNTIME_DEPENDENCIES="php7.1-bcmath" && \
    apt-get update && \
    apt-get install --yes ${BUILD_DEPENDENCIES} ${RUNTIME_DEPENDENCIES} && \
    ##
    ## Pull the archive down
    ##
    curl ${SNIPE_RELEASE_URL} \
        --location \
        --output ${WORKDIR}/snipe.tar.gz && \
    ##
    ## Unpack the archive
    ## 
    cd ${WORKDIR} && \
    tar --file=./snipe.tar.gz \
         --extract && \
    ##
    ## Compile the application
    ## 
    cd "${WORKDIR}/snipe-it-${SNIPE_VERSION}" && \
    composer install && \
    ##
    ## Install the application
    ## 
    mv "${WORKDIR}/snipe-it-${SNIPE_VERSION}" ${APP_DIR} && \
    ## -- Symlink the data from the applicaton root into the application storage volume
    ln -fs "${APP_DATA_DIR}/data/private_uploads"   "${APP_DIR}/storage/private_uploads" && \
    ln -fs "${APP_DATA_DIR}/data/uploads"           "${APP_DIR}/public/uploads" && \
    ln -fs "${APP_DATA_DIR}/dumps"                  "${APP_DIR}/storage/app/backups" && \
    ln -fs "${APP_DATA_DIR}/oauth-private.key" "${APP_DIR}/storage/oauth-private.key" && \
    ln -fs "${APP_DATA_DIR}/oauth-public.key"  "${APP_DIR}/storage/oauth-public.key" && \
    chown -R www-data:www-data ${APP_DIR} && \
    chown -R www-data:www-data /var/lib/snipeit && \
    ##
    ## Cleanup
    ##
    apt-get purge --yes ${BUILD_DEPENDENCIES} && \
    rm -rf ${HOME}/.composer

##
## Configure the applications
##
ADD etc/apache2/sites-enabled/000-default.conf /etc/apache2/sites-enabled/000-default.conf
