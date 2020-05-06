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
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash - 1>/dev/null
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - 1>/dev/null
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list 1>/dev/null
sudo apt-get update 1>/dev/null
sudo apt-get install -y nodejs 1>/dev/null
sudo apt-get install -y yarn 1>/dev/null
sudo npm install --progress false --color false -g firebase-tools
echo "Installation of system dependencies was done."
echo "Installing app dependencies..."
#Instllation of an app dependencies.
yarn install --silent
echo "Installation of app dependencies was done."
#Creating .env file with appropriate details. 
echo VUE_APP_API=https://%API_DOMAIN% >> .env
echo NODE_OPTIONS=--max-old-space-size=4096 >> .env
sed -i "s|%API_DOMAIN%|$API_DOMAIN|"g $APP_DIRECTORY/.env
#Building an app for production
yarn build --silent
#Hosting project in firebase.
firebase login --no-localhost
firebase projects:create $FIREBASE_PROJECT
sed -i "s|%FIREBASE_PROJECT%|$FIREBASE_PROJECT|"g .firebaserc
firebase deploy
echo "Visit Hosting URL to reach our portal app."
