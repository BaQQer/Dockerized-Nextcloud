
# Dockerized-Nextcloud
Dockerized Nextcloud instance with PostgreSQL, Redis and Traefik (with LetsEncrypt) with minimum setup required. 

Please note that two directories, nextcloud_app and nextcloud_db, are created, which contain the Nextcloud data and the database. These directories should be backed up! Enable maintenance mode in Nextcloud before backing up in order to ensure the integrity of your database backup - see [Tips](#Tips) on how to enable it.

## Requirements

 - Docker-compose ([https://docs.docker.com/compose/install/](https://docs.docker.com/compose/install/))
 - Docker-host reachable from the internet on 80/TCP and 443/TCP

Note that the Nextcloud instance will work without it being reachable from the internet, but Traefik will not be able to perform a LetsEncrypt TLS challenge and as such Nextcloud will work with a default Traefik SSL certificate (which will produce a browser warning).

## Installation
Copy config-sample/.env-sample to .env and edit:

    cp config-sample/.env-sample .env
    vi .env

Create network web:

    docker network create web
    
Run docker-compose:

    docker-compose up -d

Wait for nextcloud_app to initialize the database - this might take a few minutes. You can see the progress using "*docker logs -f nextcloud_app*":

    $ docker logs -f nextcloud_app
    Configuring Redis as session handler
    Initializing nextcloud 18.0.3.0 ...
    Initializing finished
    New nextcloud instance
    Installing with PostgreSQL database
    starting nextcloud installation
    Nextcloud was successfully installed
    setting trusted domains…
    System config value trusted_domains => 1 set to string nextcloud.example.com

When the output above is shown, the nextcloud_app container is ready, however, we still need to tweak the Nextcloud config in order for Nextcloud to work properly with the Traefik reverse proxy. Add the following lines to *nextcloud_app/config/config.php* with your own domain:

    'overwrite.cli.url' => 'https://nextcloud.example.com',
    'overwritehost' => 'nextcloud.example.com',
    'overwriteprotocol' => 'https',
*(See config-sample/config.php-sample for an example.*)

Next, restart the nextcloud_app container:

    docker-compose restart nextcloud_app

Your nextcloud instance should now be available at the domain you configured!

## Tips
Toggling Nextcloud maintenance mode:

    docker exec -it --user www-data nextcloud_app php occ maintenance:mode --on
    docker exec -it --user www-data nextcloud_app php occ maintenance:mode --off

