// Copyright (c) 2017, philippe. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:angular2/angular2.dart';
import 'package:angular2/router.dart';
import 'package:angular_components/angular_components.dart';
import 'dart:async';

import 'src/todo_list/todo.dart';
import 'src/todo_list/todo_list_component.dart';
import 'src/todo_list/todo_detail_component.dart';
//import 'src/todo_list/todo_list_service.dart';
import 'src/app_config.dart';
import 'in_memory_data.dart';
import 'local_data_service.dart';

// ajouté pour le service vers le serveur
import 'server_data_service.dart';



// AngularDart info: https://webdev.dartlang.org/angular
// Components info: https://webdev.dartlang.org/components

// c'est étrange qu'il faille mettre cette valeur à cet endroit, mais ça marche quand même
const APP_CONFIG = const OpaqueToken('app.config');

@Component(
  selector: 'my-app',
  styleUrls: const ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: const [materialDirectives, ROUTER_DIRECTIVES],
  providers: const [materialProviders,
                    ROUTER_PROVIDERS,
                    LocalDataService,
                    InMemoryData,
                    const Provider(APP_CONFIG, useFactory:tafConfigFactory),
                    ServerDataService
  ],
)

@RouteConfig(const [
  const Route(path: '/list', name: 'List', component:TodoListComponent),
  const Route(path: '/detail/:id', name: 'Detail', component:TodoDetailComponent),
])

class AppComponent implements OnInit {

  //
  final LocalDataService localDataService;
  final ServerDataService serverDataService;
  // pas besoin d'instancier cette classe InMemoryData car elle est 100% static
  //final InMemoryData inMemoryData;
  List<Todo> localTodoItems = [];
  List<Todo> serverTodoItems = [];
  List<Todo> todoItems = [];
  final String user;
  final String title;

  //AppComponent(this.localDataService, this.inMemoryData);
  AppComponent(@Inject(APP_CONFIG) AppConfig config, this.localDataService, this.serverDataService):title = config.title, user = config.user;

  Future<Null> ngOnInit() async {
    print("ngOnInit()...");
    // important de démarrer avec ce reset pour commencer
    InMemoryData.resetDb();
    // récupérer la liste de todoItems qui serait en localhost
    localTodoItems = await localDataService.getTodoList();

    // test de l'accès serveur
    // localTodoItems = await serverDataService.synchroTodoList(InMemoryData.giveAll());

    if (localTodoItems != null) {
      localTodoItems.forEach((todoItem) {
        InMemoryData.add(todoItem);
        // plus besoin de faire la ligne du dessous car c'est fait à la fin de la boucle
        //todoItems.add(await todoListService.create(todoItem.title));
      });
    }
    todoItems = InMemoryData.giveAll();
  }


  Future<Null> onSave() async {
    print("onsave()...");
    //localTodoItems = await todoListService.getTodoItems();
    localTodoItems = InMemoryData.giveAll();
    localDataService.saveLocal(localTodoItems);
  }

  Future<Null> onSynchro() async {
    print("onsynchro()...");
    serverTodoItems = await serverDataService.synchroTodoList(InMemoryData.giveAll());
    // todo: traiter le retour serveur
  }

}
