// Copyright (c) 2017, philippe. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:angular2/angular2.dart';
import 'package:angular2/router.dart';
import 'package:angular_components/angular_components.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'src/todo_list/todo.dart';
import 'src/todo_list/todo_list_component.dart';
import 'src/todo_list/todo_detail_component.dart';
//import 'src/todo_list/todo_list_service.dart';
import 'src/app_config.dart';
import 'src/login_component.dart';
import 'in_memory_data_service.dart';
import 'local_data_service.dart';

// ajouté pour le service vers le serveur
import 'server_data_service.dart';



// AngularDart info: https://webdev.dartlang.org/angular
// Components info: https://webdev.dartlang.org/components

// c'est étrange qu'il faille mettre cette valeur à cet endroit, mais ça marche quand même
const APP_CONFIG = const OpaqueToken('app.config');

// TODO: mystère pour comprendre cet écouteur d'évènement
abstract class OnEvent {
  /// Called when an event happens.
  void onEvent();
}

@Component(
  selector: 'my-app',
  styleUrls: const ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: const [materialDirectives, ROUTER_DIRECTIVES],
  providers: const [materialProviders,
                    ROUTER_PROVIDERS,
                    LocalDataService,
                    InMemoryDataService,
                    const Provider(APP_CONFIG, useFactory:tafConfigFactory),
                    ServerDataService,
                    // ajouté pour essayer d'couter l'évènement du composant enfant
                    const Provider(OnEvent, useExisting: LoginComponent),
  ],
)

@RouteConfig(const [
  const Route(path: '/login', name: 'Login', component:LoginComponent),
  const Route(path: '/list', name: 'List', component:TodoListComponent),
  const Route(path: '/detail/:id', name: 'Detail', component:TodoDetailComponent),
])

class AppComponent implements OnInit, OnEvent{

  //
  final LocalDataService localDataService;
  final ServerDataService serverDataService;
  // pas besoin d'instancier cette classe InMemoryData car elle est 100% static
  //final InMemoryData inMemoryData;
  //List<Todo> localTodoItems = [];
  //List<Todo> todoItems = [];
  final String user;
  final String title;
  bool connected = false;

  final DateFormat dformat = new DateFormat('yyyy-MM-dd HH:mm:ss');
  // initialisation de la date de synchro
  String dayhourSynchro = "2017-01-01 12:00:00";

  //AppComponent(this.localDataService, this.inMemoryData);
  AppComponent(@Inject(APP_CONFIG) AppConfig config, this.localDataService, this.serverDataService):title = config.title, user = config.user;

  // pour essayer d'écouter un évènement
  @override
  void onEvent() {
    print('>>> An event was triggered!');
  }

  Future<Null> ngOnInit() async {
    print("ngOnInit()...");
    String t = localDataService.getToken(user);
    if (t != null) connected = await serverDataService.checkToken(user, t);
    print("connected..." + connected.toString());
    // récupérer la date de la dernière synchro si mémorisée
    String dh = localDataService.getDayhourSync(user);
    if (dh != null) dayhourSynchro = dh;

    // important de démarrer avec ce reset pour commencer
    InMemoryDataService.resetDb();
    // récupérer la liste de todoItems qui serait en localhost
    InMemoryDataService.startWithAll(await localDataService.getTodoList());

    // là je ne sais pas encore comment faire...
    // TODO: je ne pense pas que ça soit la bonne méthode...
    //await for(String s in LoginComponent.eventStream) { print(s); });
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
    // todo: traiter le retour serveur
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
