// Copyright (c) 2017, philippe. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular_components/angular_components.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'src/routes.dart';
import 'src/todo_list/todo.dart';

import 'src/app_config.dart';

import 'in_memory_data_service.dart';
import 'local_data_service.dart';
import 'server_data_service.dart';
import 'event_bus.dart';


// AngularDart info: https://webdev.dartlang.org/angular
// Components info: https://webdev.dartlang.org/components



@Component(
  selector: 'my-app',
  styleUrls: ['app_component.css'],
  templateUrl: 'app_component.html',
  pipes: [commonPipes],
  directives: [routerDirectives,
                      ],
  providers: [materialProviders,

                    ClassProvider(ServerDataService),
                    ClassProvider(LocalDataService),
                    ClassProvider(EventBus),
                    FactoryProvider(AppConfig, appConfigFactory),

  ],
  exports: [RoutePaths, Routes],
)


class AppComponent implements OnInit {

  //
  final LocalDataService localDataService;
  final ServerDataService serverDataService;
  final EventBus eventBus;
  String user;
  String title;
  bool connected = false;
  bool isOnline = false;

  final DateFormat dformat = DateFormat('yyyy-MM-dd HH:mm:ss');
  // initialisation de la date de synchro
  DateTime dtSynchronised = null;
  DateTime dtLocaleStored = DateTime.now();

  //AppComponent(this.localDataService, this.inMemoryData);
  AppComponent(AppConfig config, this.localDataService, this.serverDataService, this.eventBus) {
    title = config.title;
    user = config.user;

    // pour essayer d'écouter un évènement
    eventBus.onEventStreamLog.listen((Event e) {
      print("event log ... "+e.type);
      if (e.type == "login") {
        connected = true;
        synchroServer();
      }
      if (e.type == "logoff") connected = false;
    });

    eventBus.onEventStreamTodoChanged.listen((String s) {
      print("event todo changed in appComponent... " + s);
      checkStorage();
    });

    eventBus.onEventStreamTodoAdded.listen((String s) {
      print("event todo added in appComponent... " + s);
      checkStorage();
    });

    window.onOffline.listen((Event e) {
      print("offline event...");
      isOnline = false;
    });

    window.onOnline.listen((Event e) {
      print("online event...");
      isOnline = true;
      // faire synchroServer
      dtSynchronised = DateTime.now();
      synchroServer();
    });
  }





  Future<Null> ngOnInit() async {
    print("ngOnInit()...");
    // important de démarrer avec ce reset pour commencer
    InMemoryDataService.resetDb();
    // récupérer la liste de todoItems qui serait en localhost
    InMemoryDataService.startWithAll(localDataService.getTodoList(user));

    String t = localDataService.getToken(user);
    if (t != null) connected = await serverDataService.checkToken(user, t);
    print("connected..." + connected.toString());

    // récupérer la date de la dernière synchro si mémorisée
    DateTime dh = localDataService.getDayhourSync(user);

    if (dh != null) {
      dtSynchronised = dh;
      print("dayhour... "+dformat.format(dh)+".");
    }

    if (connected) {
      isOnline = true;
      synchroServer();
    }
  }

  void checkStorage() {
    DateTime dtEvent = DateTime.now();
    Duration difference = dtEvent.difference(dtLocaleStored);
    if (difference.inSeconds > 30) {
      dtLocaleStored = DateTime.now();
      saveLocal();
    }
    // vérifier maintenant la synchro server, si onLine et dtSynchronised ancienne alors faire synchroServer.
    if (isOnline) {
      difference = dtEvent.difference(dtSynchronised);
      print("check synchro... difference="+difference.inSeconds.toString());
      if (difference.inSeconds > 240) {
        synchroServer();
      }
    }
  }


  Future<Null> saveLocal() async {
    print("onsave()...");
    //localTodoItems = await todoListService.getTodoItems();
    //localTodoItems = InMemoryData.giveAll();
    await localDataService.saveTodoList(InMemoryDataService.giveAll(), user);
  }

  Future<Null> synchroServer() async {
    if (dtSynchronised != null) print("onsynchro()... "+dformat.format(dtSynchronised)+".");
    else print("onsynchro()...");

    List<Todo> serverTodoItems = [];
    Todo todoItem;
    String token = localDataService.getToken(user);
    // si on connait déjà une date de synchro, ça a déjà été synchronisé
    if (dtSynchronised != null) serverTodoItems = await serverDataService.synchroTodoList(InMemoryDataService.giveAllSince(dtSynchronised), dtSynchronised, user, token);
    // sinon, il faut synchroniser tout ce qui est possible, je recherche à une date très ancienne
    else {
      serverTodoItems = await serverDataService.synchroTodoList(InMemoryDataService.giveAll(), DateTime.utc(1989, 11, 9), user, token);
      dtSynchronised = DateTime.now();
    }
    //
    if (serverTodoItems != null) serverTodoItems.forEach((serverTodoItem) {
      print("response server dealing with..." + serverTodoItem.id);
      todoItem = InMemoryDataService.giveById(serverTodoItem.id);
      if (todoItem != null) {
        if (serverTodoItem.version != "XX") {
            todoItem.dayhour = serverTodoItem.dayhour;
            todoItem.version = serverTodoItem.version;
            // securité, on teste si le titre en retour du serveur n'est pas égal à "no title!" car dans le cas contraire c'est qu'il y a un problème dans toute la partie data, sans doute qu'elle est vide sur le serveur à cause d'un bug
            if (serverTodoItem.title != "no title!") {
              todoItem.title = serverTodoItem.title;
              todoItem.description = serverTodoItem.description;
              if (serverTodoItem.done != null) todoItem.done = serverTodoItem.done;
              else todoItem.done = false;
              todoItem.tag = serverTodoItem.tag;
              todoItem.color = serverTodoItem.color;
              todoItem.end = serverTodoItem.end;
              todoItem.priority = serverTodoItem.priority;
            }
            else {
              // là par sécurité on va garder les info qui étaient présentes avant la synchro en commençant par un warning sur le title
              todoItem.title = "!BUG DATABASE LOST DATA! " + todoItem.title;
            }
        }
        else {
          InMemoryDataService.clearById(todoItem.id);
        }
      }
      else if (serverTodoItem.version != "XX") {
        InMemoryDataService.insert(serverTodoItem);
      }
      // mettre à jour la date de synchro en fonction des résultats du serveur
      if (dtSynchronised.isBefore(DateTime.parse(serverTodoItem.dayhour))) {
        dtSynchronised = DateTime.parse(serverTodoItem.dayhour);
      }
      localDataService.saveDayhourSync(user, dtSynchronised);
    });
    // faire un local save à la fin pour garder la base local en conformité
    if (serverTodoItems.length > 0) await localDataService.saveTodoList(InMemoryDataService.giveAll(), user);
  }

}
