FROM quay.io/littlemanco/apache-php:7.1-latest

## The version of the upstream snipe project
## See https://github.com/snipe/snipe-it/releases
RUN export SNIPE_VERSION="4.4.1" && \
    ##
    ## The URL to fetch the release from
    ##
    export SNIPE_RELEASE_URL="https://github.com/snipe/snipe-it/archive/v${SNIPE_VERSION}.tar.gz" && \
    export WORKDIR=$(mktemp -d) && \
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
    mv "${WORKDIR}/snipe-it-${SNIPE_VERSION}" /var/www/snipe && \
    chown -R www-data:www-data /var/www/snipe && \
    ##
    ## Cleanup
    ## 
    apt-get purge --yes ${BUILD_DEPENDENCIES}

##
## Configure the apache host
##
ADD etc/apache2/sites-enabled/000-default.conf /etc/apache2/sites-enabled/000-default.conf

