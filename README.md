# taf
A todo list in one page Angular Dart web application working inline/offline and synchronized with a server.

This application is under construction. However, the current version is functionable, even if not totaly stabilized. The source code is shared as a study case for developing PWA web application with Dart.

![Home](capture/home.jpg?raw=true "home")

## Build
To build the projet, first install Dart SDK : https://dart.dev/get-dart. Then, download the project_code folder from this repository. Within this folder, run in command line : 
```
pub global run webdev build --output=web:build
```
You will get the build folder with the functionable code. 

## Server side environment
The todo list storage is located twice, first with local storage and second with a server database. The remote access make the list available everywhere. The server side source code is with PHP and MySQL language. To make it work for your need, you have to prepare the database and to customize some files. A tiny MariaDB database is sufficient.

## Deploy
In production environement, this web application is HTML and Javascript for the client side, and PHP/MySQL for the server side. It is supposed to work on a LAMP server.

