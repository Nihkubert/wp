#!/bin/bash

docker-compose run --rm wp-cli wp db export --add-drop-table
mv ./wp/wordpress-*.sql .
gzip wordpress-*.sql