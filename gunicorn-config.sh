#!/bin/bash

NAME="shipper"
DJANGODIR=%APP_DIRECTORY%
SOCKFILE=%APP_DIRECTORY%/Misc/gunicorn.sock
USER=%USER%
GROUP=%USER_GROUP%
NUM_WORKERS=3
DJANGO_SETTINGS_MODULE=shipper.settings
DJANGO_WSGI_MODULE=shipper.wsgi

echo "Starting $NAME as `whoami`"

# Activate the virtual environment
cd $DJANGODIR
source $DJANGODIR/venv/bin/activate
export DJANGO_SETTINGS_MODULE=$DJANGO_SETTINGS_MODULE
export PYTHONPATH=$DJANGODIR:$PYTHONPATH

# Start your Django Unicorn
# Programs meant to be run under supervisor should not daemonize themselves (do not use --daemon)
exec $DJANGODIR/venv/bin/gunicorn ${DJANGO_WSGI_MODULE}:application \
  --name $NAME \
  --workers $NUM_WORKERS \
  --user=$USER --group=$GROUP \
  --bind=unix:$SOCKFILE \
  --log-level=info \
  --access-logfile='/var/log/shipper/access.log' \
  --access-logformat '%({X-Forwarded-For}i)s %({X-Remote-User-Name}o)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s"'
