#!/bin/bash

USER=$USER
USER_GROUP=$USER
USER_HOME=$(eval echo "~$USER")

source helpers.env

sudo apt-get -y autoremove 1>/dev/null
sudo apt-get -y autoclean 1>/dev/null
sudo apt-get -y update 1>/dev/null
echo "Please Wait While We Configure our App For You"
cd $USER_HOME
git clone -q https://$GIT_ACCESS_NAME:$GIT_ACCESS_TOKEN@gitlab.com/naanal/shipping/shipper
cd shipper
APP_DIRECTORY=$(eval pwd)
mkdir -p bslip email_alert import_export_files invoices invoice_temp invoice_temps mis_reports Money-Transfers netmeds_invoices temp today_slip validation_temp
cd media
mkdir -p $(awk '{print $1'} directories.txt)
cd ..
chmod -R o+w {bslip/,email_alert/,import_export_files/,invoices/,invoice_temp/,invoice_temps/,media/,mis_reports/,Money-Transfers/,netmeds_invoices/,temp/,today_slip/,validation_temp/} 
echo "Installing system dependencies..."
#Adding rabbitmq-server GPG key for installing rabbitmq-server
echo "deb https://dl.bintray.com/rabbitmq/debian xenial main" | sudo tee 1>/dev/null
wget -q -O- https://dl.bintray.com/rabbitmq/Keys/rabbitmq-release-signing-key.asc | sudo apt-key add - 1>/dev/null
#Adding python3.6 PPA repo for installing python3.6
sudo add-apt-repository -y ppa:deadsnakes/ppa >/dev/null 2>&1
#Updating the changes
sudo apt-get -y update 1>/dev/null
#installation of system dependencies
sudo apt-get install -q -y $(awk '{print $1'} system_packages.txt) 1>/dev/null
wget -q https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.3/wkhtmltox-0.12.3_linux-generic-amd64.tar.xz 
tar xf wkhtmltox-0.12.3_linux-generic-amd64.tar.xz
sudo mv wkhtmltox/bin/wkhtmlto* /usr/bin/
rm -r wkhtmltox/ 
echo "Installation of system dependencies was done."
echo "Installing shipper app dependencies..."
virtualenv venv --python=python3.6 1>/dev/null
source venv/bin/activate 
pip install -r requirements.txt 1>/dev/null 
echo "Installation of shipper app dependencies was done."
deactivate

#Configuration of celery default queue in supervisor
echo "Configuring celery default queue in supervisor..."
sudo curl -sS -o /etc/supervisor/conf.d/celery_default_queue.conf https://gist.githubusercontent.com/naanaldevelopers/a99e4286de68e931746f58d314b7acc1/raw/e5b65d0aeae6c219e1925894241514828584e75d/celery_default_queue.conf
sudo sed -i "s|%APP_DIRECTORY%|$APP_DIRECTORY|"g /etc/supervisor/conf.d/celery_default_queue.conf
sudo sed -i "s|%USER%|$USER|"g /etc/supervisor/conf.d/celery_default_queue.conf 
echo "Configuration of celery default queue was done."

#Configuration of celery priority queue in supervisor
echo "Configuring celery priority queue in supervisor..."
sudo curl -sS -o /etc/supervisor/conf.d/celery_priority.queue.conf https://gist.githubusercontent.com/naanaldevelopers/4b59c14086fc9f10119349454b4bbb1f/raw/267ec5fcd420e77d325e348100bc5a19a43c4890/celery_priority.queue.conf
sudo sed -i "s|%APP_DIRECTORY%|$APP_DIRECTORY|"g /etc/supervisor/conf.d/celery_priority.queue.conf
sudo sed -i "s|%USER%|$USER|"g /etc/supervisor/conf.d/celery_priority.queue.conf
sudo mkdir -p /var/log/celery
sudo chown -R $USER /var/log/celery
echo "Configuration of celery priority queue in supervisor was done."

#Configuration of celery beat in supervisor
echo "Configuring celery beat in supervisor..."
sudo curl -sS -o /etc/supervisor/conf.d/celery_beat.conf https://gist.githubusercontent.com/naanaldevelopers/1b4530a261cb55af3bedf0011df9d721/raw/534d2c5af4b5aaaa1ba368c21881733bca877b39/celery_beat.conf
sudo sed -i "s|%APP_DIRECTORY%|$APP_DIRECTORY|"g /etc/supervisor/conf.d/celery_beat.conf
sudo sed -i "s|%USER%|$USER|"g /etc/supervisor/conf.d/celery_beat.conf
echo "Configuration of celery beat in supervisor was done."

#Configuration of scrapyd in supervisor
echo "Configuring scrapyd in supervisor..."
sudo curl -sS -o /etc/supervisor/conf.d/scrapyd.conf https://gist.githubusercontent.com/naanaldevelopers/3bc161c9619e668279d839192a44d9c5/raw/6e4553159633708173a532083e0586b17d7606f5/scrapyd.conf
sudo sed -i "s|%APP_DIRECTORY%|$APP_DIRECTORY|"g /etc/supervisor/conf.d/scrapyd.conf
echo "Configuration of scrapyd in supervisor was done."

#Configuration of gunicorn for shipper in shell script
echo "Configuring gunicorn for shipper in shell script..."
curl -sS -o $APP_DIRECTORY/Misc/gunicorn-conf.sh https://gist.githubusercontent.com/naanaldevelopers/2ff8337d92954f4f79a8fb3c8e8c2d6b/raw/7411886d48dcc8c5922d98eb2c4c552ca95173f0/gunicorn-conf.sh
sed -i "s|%APP_DIRECTORY%|$APP_DIRECTORY|"g $APP_DIRECTORY/Misc/gunicorn-conf.sh
sed -i "s|%USER%|$USER|"g $APP_DIRECTORY/Misc/gunicorn-conf.sh
sed -i "s|%USER_GROUP%|$USER_GROUP|"g $APP_DIRECTORY/Misc/gunicorn-conf.sh
chmod u+x Misc/gunicorn-conf.sh
sudo mkdir -p /var/log/shipper
sudo chown -R $USER /var/log/shipper
echo "Configuration of gunicorn for shipper in shell script was done."

#Configuration of shipper app in supervisor
echo "Configuring shipper app in supervisor..."
sudo curl -sS -o /etc/supervisor/conf.d/shipper.conf https://gist.githubusercontent.com/naanaldevelopers/6f9bd6643212978e91d564a909541792/raw/3eb9fcde8ac02a1b13e8cb336910a15760b3aa8b/shipper_app.conf
sudo sed -i "s|%APP_DIRECTORY%|$APP_DIRECTORY|"g /etc/supervisor/conf.d/shipper.conf
sudo sed -i "s|%USER%|$USER|"g /etc/supervisor/conf.d/shipper.conf
echo "Configuration of shipper app in supervisor was done."

#Configuration of nginx for shipper app
echo "Configuring nginx for shipper app..."
sudo curl -sS -o /etc/nginx/sites-available/shipper.conf https://gist.githubusercontent.com/naanaldevelopers/10e7f03c9b47fca33ad4485e75ff5f6c/raw/52a55442cd11a9b97d9d7467255a36fb8461096b/shipper.conf
sudo sed -i "s|%APP_DIRECTORY%|$APP_DIRECTORY|"g /etc/nginx/sites-available/shipper.conf
sudo sed -i "s|%API_DOMAIN%|$API_DOMAIN|"g /etc/nginx/sites-available/shipper.conf
sudo ln -s /etc/nginx/sites-available/shipper.conf /etc/nginx/sites-enabled/shipper.conf
echo "Configuration of nginx for shipper app was done."

#Configuration of environment variable for shipper app
echo "Configuring environment variables for shipper app..."
wget -q -N https://gist.githubusercontent.com/naanaldevelopers/1a4fcc3c9e387d4b6d4a27a537d348eb/raw/d7fdf088fc92b1f4a5182735455992788666d1c3/.env
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
sed -i "s|%CHAT_API_TOKEN%|$CHAT_API_TOKEN|"g $APP_DIRECTORY/.env
sed -i "s|%CHAT_API_INSTANCE%|$CHAT_API_INSTANCE|"g $APP_DIRECTORY/.env
sed -i "s|%PRICE_APPROVAL_WHATSAPP_GROUP%|$PRICE_APPROVAL_WHATSAPP_GROUP|"g $APP_DIRECTORY/.env
sed -i "s|%DEPS_ALERT%|$DEPS_ALERT|"g $APP_DIRECTORY/.env
sed -i "s|%PRICE_APPROVAL_WHATSAPP_GROUP%|$PRICE_APPROVAL_WHATSAPP_GROUP|"g $APP_DIRECTORY/.env
sed -i "s|%DOMAINNAME%|$API_DOMAIN|"g $APP_DIRECTORY/.env
sed -i "s|%Open_Bank_Static_Token%|$Open_Bank_Static_Token|"g $APP_DIRECTORY/.env
sed -i "s|%Open_Bank_Domain%|$Open_Bank_Domain|"g $APP_DIRECTORY/.env
sed -i "s|%Spoton_MIS_PWD%|$Spoton_MIS_PWD|"g $APP_DIRECTORY/.env
sed -i "s|%AfterShip_Slug%|$AfterShip_Slug|"g $APP_DIRECTORY/.env
echo "Configuration of enviroment variable for shipper app was done."

cd $USER_HOME

sudo supervisorctl reread 1>/dev/null
sudo supervisorctl update 1>/dev/null
sudo /etc/init.d/nginx restart 1>/dev/null

echo "Setup was successfile visit '$API_DOMAIN' to ensure."
