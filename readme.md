# Dockerized Laravel PHP project setup

## adding a nginx container

starting from nginx we will define a docker-compose.yml file with list of all services we intend to define later

```yml
version: "3.8"
services:
  server:
    image: 'nginx:stable-alpine'
    ports:
      - '8000:80'
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
  # php:
  # mysql:
  # composer:
  # artisan:
  # npm:
```

## adding a php container

for php we will create a php.dockerfile inside dockerfiles folder

```dockerfile
FROM php:7.4-fpm-alpine

WORKDIR /var/www/html

RUN docker-php-ext-install pdo pdo_mysql

# we don't need a CMD here because we want the default CMD in the base image to run.
```

from the base image dockerfile in github repo of php:7.4-fpm-alpine we found that it expose port 9000 so we should update nginx.conf accordingly

```conf
        server {
    listen 80;
    index index.php index.html;
    server_name localhost;
    root /var/www/html/public;
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass php:9000; 
        ; updated php:9000 from php:3000
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }
}
```

docker-compose file updated for the php container

```yml
version: "3.8"
services:
  server:
    image: 'nginx:stable-alpine'
    ports:
      - '8000:80'
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
  php:
    build:
      context: ./dockerfiles
      dockerfile: php.dockerfile
    volumes: 
      - ./src:/var/www/html:delegated  
  # mysql:
  # composer:
  # artisan:
  # npm:
```

# adding a mysql container

for the mysql container we will first define few environment variables in a mysql.env file inside env folder

```environment
MYSQL_DATABASE=homestead
MYSQL_USER=homestead
MYSQL_PASSWORD=secret
MYSQL_ROOT_PASSWORD=secret
```

then update the docker-compose file mysql service

```yml
  mysql:
    image: mysql:5.7
    env_file:
      -./env/mysql.env
```