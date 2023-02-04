
# CI/CD for WordPress
## Preparation
We will need a virtual machine with docker and docker-compose installed.Personally, I installed on Ubuntu 20.04
https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-compose-on-ubuntu-20-04-ru
Create a wordpress directory with the command():
_____________________________________________________________________________________________
cd mkdir wordpress
_____________________________________________________________________________________________
Create a config file in the directory docker-compose.yaml
We will use: mysql, wordpress:php7.4-apache, wordpress:cli
Then edit docker-compose.yaml
_____________________________________________________________________________________________
nano docker-compose.yaml 
_____________________________________________________________________________________________
add the following content:
_____________________________________________________________________________________________
version: '3'

services:
  mysql:
    image: mysql:8
    command: --default-authentication-plugin=mysql_native_password
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: wordpress
    volumes:
      - "./db:/var/lib/mysql"

  wordpress:
    image: wordpress:php7.4-apache
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: mysql
      WORDPRESS_DB_USER: root
      WORDPRESS_DB_PASSWORD: root
      WORDPRESS_DB_NAME: wordpress
    volumes:
      - "./wp:/var/www/html/"

  wp-cli:
    image: wordpress:cli
    user: "33:33"
    environment:
      WORDPRESS_DB_HOST: mysql
      WORDPRESS_DB_USER: root
      WORDPRESS_DB_PASSWORD: root
      WORDPRESS_DB_NAME: wordpress
    volumes:
      - "./wp:/var/www/html/"
      - "./configure-wp.sh:/opt/configure-wp.sh"
      - "./sample-content.xml:/var/www/html/sample-content.xml"
   command: "bash /opt/configure-wp.sh"
_____________________________________________________________________________________________

# WordPress with docker and docker-compose
go to the /wordpress directory and start the container with the help of docker
_____________________________________________________________________________________________
docker-compose up 
_____________________________________________________________________________________________
in the end getting something similar to:
_____________________________________________________________________________________________
wp-cli_1     | 
wp-cli_1     | Processing post #68 ("t-shirt-orange") (post_type: attachment)
wp-cli_1     | -- 1 of 277 (in file sample-content.xml)
wp-cli_1     | -- Mon, 30 des 2022 12:40:22 +0000
......................................................................
wp-cli_1     | Failed to import “Order – February 6, 2015 @ 02:42 PM”: Invalid post type shop_order

All done. Have fun!
Remember to update the passwords and roles of imported users.
wp-cli_1 | Success: Finished importing from 'sample-content.xml' file.
_____________________________________________________________________________________________
Now edit the hosts file at your workplace, coming up with a domain name:
Eg
_____________________________________________________________________________________________
192.168.2.184 wpsite.by
_____________________________________________________________________________________________
We go to the address and check that everything works

# Database backup via wp-cli

Create a script to export the database
_____________________________________________________________________________________________
nano db-export.sh
_____________________________________________________________________________________________
_____________________________________________________________________________________________
!/bin/bash

docker-compose run --rm wp-cli wp db export --add-drop-table
mv ./wp/wordpress-*.sql .
gzip wordpress-*.sql
_____________________________________________________________________________________________
Making the file executable
_____________________________________________________________________________________________
chmod +x db-export.sh
_____________________________________________________________________________________________
check the work
_____________________________________________________________________________________________
./db-export.sh
_____________________________________________________________________________________________
You should see something similar to
_____________________________________________________________________________________________
Success: Exported to 'wordpress-2023-01-30-062339e.sql'.
_____________________________________________________________________________________________


Now let's write a script to import the database
_____________________________________________________________________________________________
nano db-import.sh
_____________________________________________________________________________________________
_____________________________________________________________________________________________
!/bin/bash

gunzip wordpress-*.sql.gz
mv wordpress-*.sql ./wp

dbname=`ls -l ./wp | grep sql | awk '{print $9}'`

docker-compose run --rm wp-cli wp db import $dbname
rm ./wp/$dbname
_____________________________________________________________________________________________
Making the file executable
_____________________________________________________________________________________________
chmod +x db-import.sh
_____________________________________________________________________________________________
check the work
_____________________________________________________________________________________________
./ db-import.sh
_____________________________________________________________________________________________
You should see something similar to
_____________________________________________________________________________________________
Success: Imported from 'wordpress-2023-01-30-062339e.sql'.
 _____________________________________________________________________________________________

# Create a git repository for a site template
## How to install and configure Gitlab on Ubuntu
## I'm sluggish from this article
https://ruvds.com/ru/helpcenter/kak-ustanovit-gitlab-na-ubuntu-20-04/

Before we upload our entire farm to git, we'll add a couple more files. We need to add one more script here - chmod.sh.
_____________________________________________________________________________________________
!/bin/bash
chown -R 33:33 wp/
_____________________________________________________________________________________________
We will need it to set the rights to the source of the wordpress site after the transfer. And here, we add another file to the directory - .gitignore.
_____________________________________________________________________________________________
/wp/*
/db/*
_____________________________________________________________________________________________
Now we create a wp repository in gitlab and upload everything there. First, do it in the web interface, and then go to the server console. Don't forget to add the ssh key to gitlab in order to connect to the repository.
_____________________________________________________________________________________________
git config --global user.name " name "
git config --global user.email " email "
git init
Initialized empty Git repository in /root/wordpress/.git/
git remote add wp git@gitlab.com:*********/wp.git
git add .
git commit -m "Initial commit"
git push -u wp master
_____________________________________________________________________________________________
Done, we have created a repository, which we will take as a basis for developing sites on wordpress.
To check, we create another 1 virtual machine and clone our wordpress repository
Rename the wpsite.by directory to something else wpsitetest.by
Changing host file parameters
If everything is in order, then unload the database by running the db-export.sh script. Make sure that the database file appears in the directory with the script. Now let's edit the .gitignore file, removing the /wp/* line from there, since now we will need to upload the site sources to the repository.
Next, go to git, add a new project
_____________________________________________________________________________________
 git init
 git remote add wpsitetest.by git@gitlab.com:*********/ wpsitetest.by.git
 git add .
 git commit -m "Initial commit"
 git push -u wpsitetest.by master
_____________________________________________________________________________________________

The sources of the site and the database fly into the repository.
# Somehow so far.

