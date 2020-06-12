# taf
A todo list in one page Angular Dart web application working inline/offline and synchronized with a server

This application is under construction. However, the current version is functionable, even if not totaly stabilized. The source code is shared as a study case for developing PWA web application with Dart.

![Home](capture/home.jpg?raw=true "home")

## Server side environment
The todo list storage is located within a local storage and within a server database, to make the list available everywhere. The server side source code is with PHP and MySQL language. To make this application working for your need, you have to prepare a database and to customize some files.

## Build
To build the projet, first install Dart SDK : https://dart.dev/get-dart. Download the project_code folder. Within this folder,  run in command line : 
```
pub global run webdev build --output=web:build
```
You will get the build folder with the functionable code. 

## Deploy
In production environement, this web application is HTML and Javascript for the client side, and PHP/MySQL for the server side. It is supposed to work on a LAMP server.

