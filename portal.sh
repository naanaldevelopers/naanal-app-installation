#!/bin/bash

USER=$USER
USER_GROUP=$USER
USER_HOME=$(eval echo "~$USER")

source helpers.env

cd $USER_HOME
echo "Please wait we're configuring our app for you."
#Cloning repository.
git clone -q https://$GIT_ACCESS_NAME:$GIT_ACCESS_TOKEN@gitlab.com/naanal/scm/portal.git 1>/dev/null
cd portal
APP_DIRECTORY=$(eval pwd)
echo "Installing system dependencies..."
#Installation of needed system packages for an app.
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash - 1>/dev/null
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - 1>/dev/null
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list 1>/dev/null
sudo apt-get update 1>/dev/null
sudo apt-get install -y nodejs 1>/dev/null
sudo apt-get install -y yarn 1>/dev/null
sudo npm install -g firebase-tools > /dev/null 2>&1
echo "Installation of system dependencies was done."
echo "Installing app dependencies..."
#Instllation of an app dependencies.
yarn install --silent > /dev/null 2>&1
echo "Installation of app dependencies was done."
#Creating .env file with appropriate details.
echo VUE_APP_API=https://%API_DOMAIN% >> .env
sed -i "s|%API_DOMAIN%|$API_DOMAIN|"g $APP_DIRECTORY/.env
#Building an app for production
export NODE_OPTIONS=--max-old-space-size=4096
yarn run build
echo "Production build success"
#Hosting project in firebase.
firebase use $FIREBASE_PROJECT_ID
firebase deploy
echo "Visit Hosting URL to reach app."
