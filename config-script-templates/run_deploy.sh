#!/bin/bash
APP_DIRECTORY=%APP_DIRECTORY%
cd $APP_DIRECTORY
source .env
git pull https://$GIT_ACCESS_NAME:$GIT_ACCESS_TOKEN@gitlab.com/naanal/shipping/shipper.git
python manage.py migrate
python manage.py makemigrations --merge
python manage.py migrate
