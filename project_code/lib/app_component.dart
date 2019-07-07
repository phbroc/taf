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

//import 'src/todo_list/todo_list_component.dart';
//import 'src/todo_list/todo_add_component.dart';
//import 'src/todo_list/todo_detail_component.dart';
//import 'src/tag_list/tag_list_component.dart';
//import 'src/dashboard_component.dart';

import 'src/app_config.dart';
import 'src/login_component.dart';

import 'in_memory_data_service.dart';
import 'local_data_service.dart';
import 'server_data_service.dart';
import 'event_bus.dart';


// AngularDart info: https://webdev.dartlang.org/angular
// Components info: https://webdev.dartlang.org/components

// c'est étrange qu'il faille mettre cette valeur à cet endroit, mais ça marche quand même
const APP_CONFIG = OpaqueToken('app.config');


@Component(
  selector: 'my-app',
  styleUrls: ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: [routerDirectives,
                      ],
  providers: [materialProviders,

                    ClassProvider(ServerDataService),
                    ClassProvider(LocalDataService),
                    ClassProvider(InMemoryDataService),
                    ClassProvider(EventBus),

                    Provider(APP_CONFIG, useFactory:tafConfigFactory),

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

  final DateFormat dformat = new DateFormat('yyyy-MM-dd HH:mm:ss');
  // initialisation de la date de synchro
  String dayhourSynchro = "2017-01-01 12:00:00";

  //AppComponent(this.localDataService, this.inMemoryData);
  AppComponent(@Inject(APP_CONFIG) AppConfig config, this.localDataService, this.serverDataService, this.eventBus) {
    title = config.title;
    user = config.user;

    // pour essayer d'écouter un évènement
    eventBus.onEventStreamLog.listen((Event e) {
      print("event log ... "+e.type);
      if (e.type == "login") connected = true;
      if (e.type == "logoff") connected = false;
    });
  }





  Future<Null> ngOnInit() async {
    print("ngOnInit()...");
    // important de démarrer avec ce reset pour commencer
    InMemoryDataService.resetDb();
    // récupérer la liste de todoItems qui serait en localhost
    InMemoryDataService.startWithAll(localDataService.getTodoList());

    String t = localDataService.getToken(user);
    if (t != null) connected = await serverDataService.checkToken(user, t);
    print("connected..." + connected.toString());
    // récupérer la date de la dernière synchro si mémorisée
    String dh = localDataService.getDayhourSync(user);
    if (dh != null) dayhourSynchro = dh;




  }


  Future<Null> onSave() async {
    print("onsave()...");
    //localTodoItems = await todoListService.getTodoItems();
    //localTodoItems = InMemoryData.giveAll();
    await localDataService.saveLocal(InMemoryDataService.giveAll());
  }

  Future<Null> onSynchro() async {
    print("onsynchro()...");
    DateTime dateSynchro = DateTime.parse(dayhourSynchro);
    List<Todo> serverTodoItems = [];
    Todo todoItem;
    String token = localDataService.getToken(user);
    serverTodoItems = await serverDataService.synchroTodoList(InMemoryDataService.giveAllSince(dateSynchro), dayhourSynchro, user, token);
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
      if (dateSynchro.isBefore(DateTime.parse(serverTodoItem.dayhour))) {
        dayhourSynchro = serverTodoItem.dayhour;
        localDataService.saveDayhourSync(user, dayhourSynchro);
      }
    });
    // faire un local save à la fin pour garder la base local en conformité
    if (serverTodoItems.length > 0) await localDataService.saveLocal(InMemoryDataService.giveAll());
  }

}
