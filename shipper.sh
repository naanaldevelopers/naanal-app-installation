#!/bin/bash

USER=$USER
USER_GROUP=$USER
USER_HOME=$(eval echo "~$USER")

source helpers.env

sudo echo -ne '[#........................](5%) Initializing set-up.\r'
sleep 1
echo -ne '[##.......................](10%) Initializing set-up.\r'
sleep 1
echo -ne '[###......................](15%) Initializing set-up.\r'
sleep 1
echo -ne '[#####....................](20%) Initial server set-up.\r'
#initial server setup.
sudo sed -i "s|deb cdrom|#deb cdrom|"g /etc/apt/sources.list
sudo apt-get -y autoremove 1>/dev/null
sudo apt-get -y autoclean 1>/dev/null
sudo apt-get -y update 1>/dev/null


echo -ne '[##########...............](40%) Processing system packages installation.\r'
#python minimal installation.
sudo apt-get install python-minimal software-properties-common >/dev/null 2>&1
#set-up rabbitmq-server apt repo.
echo "deb https://dl.bintray.com/rabbitmq/debian xenial main" | sudo tee >/dev/null 2>&1
wget -q -O- https://dl.bintray.com/rabbitmq/Keys/rabbitmq-release-signing-key.asc | sudo apt-key add - >/dev/null 2>&1
#adding python3.6 repo.
sudo add-apt-repository -y ppa:deadsnakes/ppa >/dev/null 2>&1
#updating the system.
sudo apt-get -y update >/dev/null 2>&1
#installing system packages.
wget -q -N https://raw.githubusercontent.com/naanaldevelopers/naanal-app-installation/master/system_packages.txt
sudo apt-get install -q -y $(awk '{print $1'} system_packages.txt) >/dev/null 2>&1
#wkhtmltopdf set-up
wget -q -N https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.3/wkhtmltox-0.12.3_linux-generic-amd64.tar.xz 
sudo tar xvf wkhtmltox-0.12.3_linux-generic-amd64.tar.xz 1>/dev/null
sudo mv wkhtmltox/bin/wkhtmlto* /usr/bin/
sudo rm -r wkhtmltox/
rm  wkhtmltox-0.12.3_linux-generic-amd64.tar.xz
wget -q -N https://github.com/adnanh/webhook/releases/download/2.6.6/webhook-linux-amd64.tar.gz 
tar -xf webhook-linux-amd64.tar.gz
sudo mv webhook-linux-amd64/webhook /usr/local/bin
rm -rf webhook-linux-amd64*


echo -ne '[###############..........](60%) Processing app dependencies installation.\r'
#cloning the project by git.
git clone -q https://$GIT_ACCESS_NAME:$GIT_ACCESS_TOKEN@gitlab.com/naanal/shipping/shipper.git
cd shipper
#evaluation of app directory.
APP_DIRECTORY=$(eval pwd)
#essential directories manipulation.
mkdir -p bslip email_alert import_export_files invoices invoice_temp invoice_temps mis_reports Money-Transfers netmeds_invoices temp today_slip validation_temp
cd media
mkdir -p $(awk '{print $1'} directories.txt)
cd ..
chmod -R o+w {bslip/,email_alert/,import_export_files/,invoices/,invoice_temp/,invoice_temps/,media/,mis_reports/,Money-Transfers/,netmeds_invoices/,temp/,today_slip/,validation_temp/}
#virtual environment creation and requirements installation.
virtualenv venv --python=python3.6 1>/dev/null
source venv/bin/activate 
pip install -r requirements.txt >/dev/null 2>&1
deactivate


echo -ne '[####################.....](80%) Processing app configuration.\r'
#Configuration of celery default queue in supervisor
sudo curl -sS -o /etc/supervisor/conf.d/celery_default_queue.conf https://raw.githubusercontent.com/naanaldevelopers/naanal-app-installation/master/config-file-templates/supervisor/celery_default_queue.conf
sudo sed -i "s|%APP_DIRECTORY%|$APP_DIRECTORY|"g /etc/supervisor/conf.d/celery_default_queue.conf
sudo sed -i "s|%USER%|$USER|"g /etc/supervisor/conf.d/celery_default_queue.conf 

#Configuration of celery priority queue in supervisor
sudo curl -sS -o /etc/supervisor/conf.d/celery_priority.queue.conf https://raw.githubusercontent.com/naanaldevelopers/naanal-app-installation/master/config-file-templates/supervisor/celery_priority.queue.conf
sudo sed -i "s|%APP_DIRECTORY%|$APP_DIRECTORY|"g /etc/supervisor/conf.d/celery_priority.queue.conf
sudo sed -i "s|%USER%|$USER|"g /etc/supervisor/conf.d/celery_priority.queue.conf
sudo mkdir -p /var/log/celery
sudo chown -R $USER /var/log/celery

#Configuration of celery beat in supervisor
sudo curl -sS -o /etc/supervisor/conf.d/celery_beat.conf https://raw.githubusercontent.com/naanaldevelopers/naanal-app-installation/master/config-file-templates/supervisor/celery_beat.conf
sudo sed -i "s|%APP_DIRECTORY%|$APP_DIRECTORY|"g /etc/supervisor/conf.d/celery_beat.conf
sudo sed -i "s|%USER%|$USER|"g /etc/supervisor/conf.d/celery_beat.conf

#Configuration of scrapyd in supervisor
sudo curl -sS -o /etc/supervisor/conf.d/shipper_scraping.conf https://raw.githubusercontent.com/naanaldevelopers/naanal-app-installation/master/config-file-templates/supervisor/shipper_scraping.conf
sudo sed -i "s|%APP_DIRECTORY%|$APP_DIRECTORY|"g /etc/supervisor/conf.d/shipper_scraping.conf

#Configuration of gunicorn for shipper in shell script
curl -sS -o $APP_DIRECTORY/Misc/run-shipper.sh https://raw.githubusercontent.com/naanaldevelopers/naanal-app-installation/master/config-script-templates/gunicorn/run-shipper.sh
sed -i "s|%APP_DIRECTORY%|$APP_DIRECTORY|"g $APP_DIRECTORY/Misc/run-shipper.sh
sed -i "s|%USER%|$USER|"g $APP_DIRECTORY/Misc/run-shipper.sh
sed -i "s|%USER_GROUP%|$USER_GROUP|"g $APP_DIRECTORY/Misc/run-shipper.sh
chmod u+x Misc/run-shipper.sh
sudo mkdir -p /var/log/shipper
sudo chown -R $USER /var/log/shipper

#Configuration of shipper app in supervisor
sudo curl -sS -o /etc/supervisor/conf.d/shipper.conf https://raw.githubusercontent.com/naanaldevelopers/naanal-app-installation/master/config-file-templates/supervisor/shipper.conf
sudo sed -i "s|%APP_DIRECTORY%|$APP_DIRECTORY|"g /etc/supervisor/conf.d/shipper.conf
sudo sed -i "s|%USER%|$USER|"g /etc/supervisor/conf.d/shipper.conf

#Configuration of webhook
sudo curl -sS -o /etc/supervisor/conf.d/webhooks.conf https://raw.githubusercontent.com/naanaldevelopers/naanal-app-installation/master/config-file-templates/supervisor/webhooks.conf
sudo sed -i "s|%USER_HOME%|$USER_HOME|"g /etc/supervisor/conf.d/webhooks.conf

#Incremental deployment
curl -sS -o Misc/run_shipper_deploy.sh https://raw.githubusercontent.com/naanaldevelopers/naanal-app-installation/master/config-script-templates/feature-deployment/run_shipper_deploy.sh
chmod u+x Misc/run_shipper_deploy.sh
sed -i "s|%APP_DIRECTORY%|$APP_DIRECTORY|"g Misc/run_shipper_deploy.sh
sed -i "s|%GIT_ACCESS_NAME%|$GIT_ACCESS_NAME|"g Misc/run_shipper_deploy.sh
sed -i "s|%GIT_ACCESS_TOKEN%|$APP_DIRECTORY|"g Misc/run_shipper_deploy.sh
mkdir -p $USER_HOME/webhooks
curl -sS -o $USER_HOME/webhooks/run_shipper_deploy.json https://raw.githubusercontent.com/naanaldevelopers/naanal-app-installation/master/webhooks/run_shipper_deploy.json
sed -i "s|%APP_DIRECTORY%|$APP_DIRECTORY|"g $USER_HOME/webhooks/run_shipper_deploy.json

#Configuration of nginx for shipper app
sudo curl -sS -o /etc/nginx/sites-available/shipper.conf https://raw.githubusercontent.com/naanaldevelopers/naanal-app-installation/master/config-file-templates/nginx/shipper.conf
sudo sed -i "s|%APP_DIRECTORY%|$APP_DIRECTORY|"g /etc/nginx/sites-available/shipper.conf
sudo sed -i "s|%API_DOMAIN%|$API_DOMAIN|"g /etc/nginx/sites-available/shipper.conf
sudo ln -s /etc/nginx/sites-available/shipper.conf /etc/nginx/sites-enabled/shipper.conf

#Configuration of environment variable for shipper app
wget -q -N https://raw.githubusercontent.com/naanaldevelopers/naanal-app-installation/master/.env-template-for-shipper/.env
sed -i "s|%DB_USER%|$DB_USER|"g $APP_DIRECTORY/.env
sed -i "s|%DB_PASSWORD%|$DB_PASSWORD|"g $APP_DIRECTORY/.env
sed -i "s|%DB_HOST%|$DB_HOST|"g $APP_DIRECTORY/.env
sed -i "s|%DB_NAME%|$DB_NAME|"g $APP_DIRECTORY/.env
sed -i "s|%APP_DIRECTORY%|$APP_DIRECTORY|"g $APP_DIRECTORY/.env
sed -i "s|%EMAIL_VERIFY_URL%|$EMAIL_VERIFY_URL|"g $APP_DIRECTORY/.env
sed -i "s|%AWS_ACCESS_KEY_ID%|$AWS_ACCESS_KEY_ID|"g $APP_DIRECTORY/.env
sed -i "s|%AWS_SECRET_ACCESS_KEY%|$AWS_SECRET_ACCESS_KEY|"g $APP_DIRECTORY/.env
sed -i "s|%EMAIL_HOST_USER%|$EMAIL_HOST_USER|"g $APP_DIRECTORY/.env
sed -i "s|%EMAIL_HOST_PASSWORD%|$EMAIL_HOST_PASSWORD|"g $APP_DIRECTORY/.env
sed -i "s|%DEFAULT_FROM_EMAIL%|$DEFAULT_FROM_EMAIL|"g $APP_DIRECTORY/.env
sed -i "s|%ADMIN_EMAIL%|$ADMIN_EMAIL|"g $APP_DIRECTORY/.env
sed -i "s|%CONTACT_EMAIL%|$CONTACT_EMAIL|"g $APP_DIRECTORY/.env
sed -i "s|%AWS_STORAGE_BUCKET_NAME%|$AWS_STORAGE_BUCKET_NAME|"g $APP_DIRECTORY/.env
sed -i "s|%NETMEDS_EMAILS%|$NETMEDS_EMAILS|"g $APP_DIRECTORY/.env
sed -i "s|%POD_STORE%|$POD_STORE|"g $APP_DIRECTORY/.env
sed -i "s|%AWS_CUSTOMER_INVOICE_BUCKET%|$AWS_CUSTOMER_INVOICE_BUCKET|"g $APP_DIRECTORY/.env
sed -i "s|%EWAYBILL_XLSX_BUCKET%|$EWAYBILL_XLSX_BUCKET|"g $APP_DIRECTORY/.env
sed -i "s|%CONSOLIDATED_EWAYBILL_XLSX_BUCKET%|$CONSOLIDATED_EWAYBILL_XLSX_BUCKET|"g $APP_DIRECTORY/.env
sed -i "s|%AWS_NAANAL_LABEL_BUCKET%|$AWS_NAANAL_LABEL_BUCKET|"g $APP_DIRECTORY/.env
sed -i "s|%BOOKING_SLIP_BUCKET%|$BOOKING_SLIP_BUCKET|"g $APP_DIRECTORY/.env
sed -i "s|%SCRAP_URL%|$SCRAP_URL|"g $APP_DIRECTORY/.env
sed -i "s|%IP_STACK%|$IP_STACK|"g $APP_DIRECTORY/.env
sed -i "s|%RECALCULATE_RECEIVE_EMAIL%|$RECALCULATE_RECEIVE_EMAIL|"g $APP_DIRECTORY/.env
sed -i "s|%STATUS_MISMATCH_EMAIL%|$STATUS_MISMATCH_EMAIL|"g $APP_DIRECTORY/.env
sed -i "s|%TRACKING_ERROR_EMAIL%|$TRACKING_ERROR_EMAIL|"g $APP_DIRECTORY/.env
sed -i "s|%RIVIGO_ORDER_CREATOR%|$RIVIGO_ORDER_CREATOR|"g $APP_DIRECTORY/.env
sed -i "s|%SENTRY%|$SENTRY|"g $APP_DIRECTORY/.env
sed -i "s|%CHAT_API_TOKEN%|$CHAT_API_TOKEN|"g $APP_DIRECTORY/.env
sed -i "s|%CHAT_API_INSTANCE%|$CHAT_API_INSTANCE|"g $APP_DIRECTORY/.env
sed -i "s|%PRICE_APPROVAL_WHATSAPP_GROUP%|$PRICE_APPROVAL_WHATSAPP_GROUP|"g $APP_DIRECTORY/.env
sed -i "s|%DEPS_ALERT%|$DEPS_ALERT|"g $APP_DIRECTORY/.env
sed -i "s|%PRICE_APPROVAL_WHATSAPP_GROUP%|$PRICE_APPROVAL_WHATSAPP_GROUP|"g $APP_DIRECTORY/.env
sed -i "s|%API_DOMAIN%|$API_DOMAIN|"g $APP_DIRECTORY/.env
sed -i "s|%Open_Bank_Static_Token%|$Open_Bank_Static_Token|"g $APP_DIRECTORY/.env
sed -i "s|%Open_Bank_Domain%|$Open_Bank_Domain|"g $APP_DIRECTORY/.env
sed -i "s|%Spoton_MIS_PWD%|$Spoton_MIS_PWD|"g $APP_DIRECTORY/.env
sed -i "s|%AfterShip_Slug%|$AfterShip_Slug|"g $APP_DIRECTORY/.env


echo -ne '[#########################](100%) Finalizing set-up.\r'
sudo supervisorctl reread 1>/dev/null
sudo supervisorctl update 1>/dev/null
sudo /etc/init.d/nginx restart 1>/dev/null

echo "setup was successfile visit '$API_DOMAIN' to ensure."
