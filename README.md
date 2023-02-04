# wp
## Для старта
Создаем VM на Ubuntu установим туда docker и docker-compose.(https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-compose-on-ubuntu-20-04-ru)
Создаем на ней директорию wordpress.
# cd ~ && mkdir wordpress && cd wordpress
Создаем в  конфигурационный файл docker-compose.yaml
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
#      - "./sample-content.xml:/var/www/html/sample-content.xml"
    command: "bash /opt/configure-wp.sh"

Запускаем контейнер в интерактивном режиме проверил что рам потом включил в режиме домена 
Все гуд 
Идем дальше 
Настраиваем бэкап, юзал WP-cli
Скрипт для экспорта + импорта 
Проверяю чтоб все работало 
Создал VM на Ubuntu 20.04 2ядра 2 гб установил гитлаб при проверке выдавал ошибку 502 добавил еще 2 гига памяти гит завелся.
Созаем скрипты для выставления прав на исходники сайта wordpress после переноса И сюда же, в директорию добавляем еще один файл - .gitignore. #/wp/* /db/*
Создал репозиторий WP в гитлаб заливаем все туда/
Затем тестируем 

Создаем виртуалку клонируем репозиторий, запускаем контейнеры выгружаем базу данных, загружаем в гитлаб.
Как-то так.

# git clone 
Переименовываем директорию wp и удаляем там папку .git. Для каждого сайта будем создавать отдельный именной репозиторий и с ним работать. Переходим в переименовоную папку и редактируем configure-wp.sh под нужды этого проекта. Обязательно укажите правильный url сайта. После этого запускаем контейнеры.

# docker-compose up
Дожидаемся запуска контейнеров и проверяем работу сайта. Не забудьте отредактировать файл hosts.
Если все в порядке, то выгрузим базу данных, запустив скрипт db-export.sh. Убедитесь, что файл с базой появился в директории со скриптом. Теперь отредактируем файл .gitignore, удалив оттуда строку с /wp/*, так как теперь нам нужно будет загрузить исходники сайта в репозиторий.

Далее идем в git, добавляем новый проект с новым названием и загружаем туда репозиторий из директории.

# git init
# git remote add site02.ru git@gitlab.com:zeroxzed/site02.ru.git
# git add .
# git commit -m "Initial commit"
# git push -u site02.ru master
В репозиторий улетают исходники сайта и база данных.
