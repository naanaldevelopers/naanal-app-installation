**README**

##### Download helpers.env by running the following commands and edit with appropriate details using any one of the text editor.
```
cd ~
wget -q -N https://raw.githubusercontent.com/naanaldevelopers/naanal-app-installation/master/helpers.env
```
##### Run the following commands on your terminal to install shipper. (Give sudo password of your server if it’s ask)
```
cd ~
wget -q -N https://raw.githubusercontent.com/naanaldevelopers/naanal-app-installation/master/shipper.sh
chmod u+x shipper.sh
./shipper.sh
```
##### Run the following quoted commands on your terminal to install naanal portal app. (Give sudo password of your server if it’s ask)
```
cd ~
wget -q -N https://raw.githubusercontent.com/naanaldevelopers/naanal-app-installation/master/portal.sh
chmod u+x portal.sh
./portal.sh
```
> During this process firebase asking you to login. you can use the url returned by your terminal on any browser, get the token and use it here.(Highlighted on yellow). Make sure you are using same login used to create a firebase project.
