**README**

##### Download helpers.env by running below quoted commands and edit using any one of the text editor with appropriate details.
```
cd ~
wget -q -N https://gist.githubusercontent.com/naanaldevelopers/f7571bd468b16545cb512d351771dfe6/raw/59e1c77a77c860c4835ed288fb724317b69415a4/helpers.env
```
##### Run the following quoted commands on your terminal to install naanal shipper app. (Give sudo password of your server if it’s ask)
```
cd ~
wget -q -N https://gist.githubusercontent.com/naanaldevelopers/146eb28bf402018f89aadf1f1a60c63f/raw/cfe776d4ea55169f317982a598e258417ace5d61/shipper.sh
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
wget -q -N https://gist.githubusercontent.com/naanaldevelopers/bc45a10c44e507f92ff50df7936aa5c0/raw/b8b422e2731b80a71f301a467828d0e11caea4aa/portal.sh
chmod u+x portal.sh
./portal.sh
```
