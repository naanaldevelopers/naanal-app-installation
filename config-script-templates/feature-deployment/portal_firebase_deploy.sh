#!/bin/bash
APP_DIRECTORY=%APP_DIRECTORY%
cd $APP_DIRECTORY
source .env
git pull https://$GIT_ACCESS_NAME:$GIT_ACCESS_TOKEN@gitlab.com/naanal/scm/portal.git
yarn install
export NODE_OPTIONS=--max-old-space-size=4096
yarn run build
firebase deploy
