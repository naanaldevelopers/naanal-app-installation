**README**
##### Follow the steps to create firebase project.
```
1. Go to https://console.firebase.google.com/
2. Sign in with your mail
3. Locate and click 'Add Project'
3. Enter your desired project name, in below of the project name you entered you will find unique id of the project use this id in helpers.env
4. Disable Google Analytics in next step.
5. Next -> Create Project -> Done.
```
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
>Login to the firebase on you server use ```firebase login --no-localhost``` this will return url you can use the url on any browser to login, with same mail used to create firebasae app, get token and use it here.
##### Run the following quoted commands on your terminal to install naanal portal app. (Give sudo password of your server if it’s ask)
```
cd ~
wget -q -N https://raw.githubusercontent.com/naanaldevelopers/naanal-app-installation/master/portal.sh
chmod u+x portal.sh
./portal.sh
```
