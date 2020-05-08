**README**

##### Download helpers.env by running below quoted commands and edit using any one of the text editor with appropriate details.
```
cd ~
wget -q -N https://raw.githubusercontent.com/naanaldevelopers/naanal-app-installation/master/helpers.env
```
##### Run the following quoted commands on your terminal to install naanal shipper app. (Give sudo password of your server if it’s ask)
```
cd ~
wget -q -N https://raw.githubusercontent.com/naanaldevelopers/naanal-app-installation/master/shipper.sh
chmod u+x shipper.sh
./shipper.sh
```
##### Run the following quoted commands to setting up firebase for host an app.
```
firebase login --no-localhost
```
> During this you can use the url returned by your terminal on your browser, get the token and use it here.

> If it's ask any questions during the process please hit an enter to choose default answer.

##### Run the following quoted commands on your terminal to install naanal portal app. (Give sudo password of your server if it’s ask)
```
cd ~
wget -q -N https://raw.githubusercontent.com/naanaldevelopers/naanal-app-installation/master/portal.sh
chmod u+x portal.sh
./portal.sh
```
