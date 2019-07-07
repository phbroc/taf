// Copyright (c) 2017, philippe. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

//import 'dart:async';
//import 'package:angular2/platform/common.dart';
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import '../route_paths.dart';
//import 'package:angular_forms/angular_forms.dart';
import 'package:angular_components/angular_components.dart';
import 'package:intl/intl.dart';

//import 'package:taf/src/app_config.dart';

import 'todo.dart';
import '../../in_memory_data_service.dart';
import 'todo_detail_component.dart';
import 'todo_add_component.dart';
import '../../event_bus.dart';

// très bizarre, je ne peux plus importer dart.html sans faire planter la page... Et j'en ai besoin pour étudier l'event...
// import 'dart:html';

// là je n'arrive pas du tout à fiare fonctionner l'import de app_config, ça provoque un bug, alors que dans app_component ça fonctionne
// la piste est éventuellement que je n'ai pas besoin de refournir le provider (comme vu pour le InMemoryData), donc je n'ai peut-être pas besoin d'appeler la const APP_CONFIG???
// c'est étrange qu'il faille mettre cette valeur à cet endroit, mais ça marche quand même
// const APP_CONFIG = const OpaqueToken('app.config');


@Component(
  selector: 'todo-list',
  styleUrls: ['todo_list_component.css'],
  templateUrl: 'todo_list_component.html',
  directives: [
    coreDirectives,
    TodoDetailComponent,
    TodoAddComponent,
    MaterialCheckboxComponent,
    MaterialIconComponent,
    MaterialFabComponent,
  ],
  providers: [materialProviders],
)


class TodoListComponent implements OnActivate {
  //final TodoListService todoListService;
  //final InMemoryData inMemoryData;
  List<Todo> todoItems = [];
  Todo selectedTodo;

  final Router _router;
  final Location _location;

  String _totoItemUrl(String id) => RoutePaths.detail.toUrl(parameters: {idParam: '$id'});

  String tag;

  final String user = "PBD";
  //final String user;

  final nformat = NumberFormat("000000");
  final dformat = DateFormat('yyyy-MM-dd HH:mm:ss');

  final EventBus eventBus;


  //TodoListComponent(this.inMemoryData);
  //TodoListComponent(@Inject(APP_CONFIG) AppConfig config, this._router):user = config.user;
  TodoListComponent(this._router, this._location, this.eventBus) {
    eventBus.onEventStreamTodoAdd.asBroadcastStream().listen((String s) {
      print("event totoadd ... " + s);
      if (s == "todoadded") refreshList();
    });
  }

  @override
  void onActivate(_, RouterState current) {
    //todoItems = await todoListService.getTodoItems();
    //tag = _routeParams.get('tag');
    tag = getTag(current.parameters);
    refreshList();
    print("List onActivate..." + todoItems.length.toString());
  }

  void refreshList() {
    if (tag == "all") todoItems = InMemoryDataService.giveAll();
    else if ((tag != null) && (tag != "") && (tag != "all")) todoItems = InMemoryDataService.giveAllByTag(tag);
    else todoItems = InMemoryDataService.giveAll();
  }

  void remove(Todo todoItem) {
    // await todoListService.delete(todoItem.id);
    // await InMemoryDataService.clearById(todoItem.id);
    // plus besoin de retirer le todoitem à la liste todoItems car il y a surement un binding automatique avec la ligne du dessus
    // todoItems.remove(todoItem);
    // nouvelle stratégie = on va marquer l'item comme étant à supprimer et on ne va plus l'afficher
    todoItem.version = "DD";
    var now = DateTime.now();
    todoItem.dayhour = dformat.format(now);
  }



  Future<NavigationResult> gotoDetail(Todo todoItem) => _router.navigate(_totoItemUrl(todoItem.id));

  void doneOnOff(Todo todoItem, bool checked) {
    print("doneOnOff... " + todoItem.id + " -> " + checked.toString());
    var now = DateTime.now();
    todoItem.dayhour = dformat.format(now);
    todoItem.done = checked;
  }

  void goBack() => _location.back();



}
