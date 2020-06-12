# taf
A todo list in one page Angular Dart web application working inline/offline and synchronized with a server.

This application is under construction. However, the current version is functionable, even if not totaly stabilized. The source code is shared as a study case for developing PWA web application with Dart.

## Build
To build the projet, first install Dart SDK : https://dart.dev/get-dart. Then, download the project_code folder from this repository. Within this folder, run in command line : 
```
pub global run webdev build --output=web:build
```
You will get the build folder with the functionable code. 

## Server side environment
The todo list storage is located twice, first with local storage (on a mobile device) and second with a server database. This remote storage make the list available everywhere. The server side source code is with PHP and MySQL language. To make it work for your need, you have to prepare the database and to customize some files. A tiny MariaDB database is sufficient.

## Deploy
The build folder is supposed to be hosted on a LAMP server. When you're ready with api/server files, put all the builded project on the server and go to the index.html file to start the application.

![Home](capture/home.jpg?raw=true "home")

