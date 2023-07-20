# docker-template

This project intends to provide a php docker configuration as a template for new symfony
projects - using a Makefile with predefined tasks. The tasks can be rewritten to your needs. 

## docker-compose / make

The simplest way to build/start the container is to use `make` by 
running:

```console
jdoe@host:/home/jdoe/projects/app $ make build
``` 
Execute the Dockerfile to build an image for the app and bring up the 
container with:

```console
jdoe@host:/home/jdoe/projects/app $ make up
```
The Dockerfile installs SymfonyCli, xDebug, Yarn and Node.js into the app
image.

## new / existing project
Start a new project with a fresh symfony-skeleton by running:

```console
jdoe@host:/home/jdoe/projects/app $ make symfony-install
```
When there exist a project already create a directory app and copy and paste the files/folders
into the app directory and run:

```console
jdoe@host:/home/jdoe/projects/app $ make composer-install
```
Another option is to hook into the running container to run your 
php software inside its environment:
```console
jdoe@host:/home/jdoe/projects/app $ make bash app
root@app:/var/www/app# php --version
PHP 8.0.3 (cli) (built: Apr 10 2021 13:25:28) ( NTS )
Copyright (c) The PHP Group
Zend Engine v4.0.3, Copyright (c) Zend Technologies
    with Zend OPcache v8.0.3, Copyright (c), by Zend Technologies
    with Xdebug v3.0.3, Copyright (c) 2002-2021, by Derick Rethans
```

## development and production stages

The docker image has two stages for development and production. This way development can take 
place inside the same environment. For the development stage, debugging settings are enabled.
### docker-compose.yml & docker-compose.override.yml

The basic docker-compose.yml is intended to be extended by overrides and is therefore very 
minimal (no port mappings e.g.). Extend it by adding your customized override file. Templates 
are provided for development and production. The development override mounts the project 
directory from the host machine to enable rapid development inside the container.

## composer (php)
The latest master version of composer (https://getcomposer.org) is installed. Use it from a 
running container to manage your app:

```console
jdoe@host:/home/jdoe/projects/app $ make bash app
root@app:/var/www/app# composer --version
Composer version 2.2.4 2022-01-08 12:30:42
```

