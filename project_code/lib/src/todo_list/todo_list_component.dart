// Copyright (c) 2017, philippe. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

//import 'dart:async';
//import 'package:angular2/platform/common.dart';
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
//import 'package:angular_forms/angular_forms.dart';
import 'package:angular_components/angular_components.dart';
import 'package:intl/intl.dart';

//import 'package:taf/src/app_config.dart';

import 'todo.dart';
import '../../in_memory_data_service.dart';
import 'todo_detail_component.dart';
import '../utils/converter.dart';

// là je n'arrive pas du tout à fiare fonctionner l'import de app_config, ça provoque un bug, alors que dans app_component ça fonctionne
// la piste est éventuellement que je n'ai pas besoin de refournir le provider (comme vu pour le InMemoryData), donc je n'ai peut-être pas besoin d'appeler la const APP_CONFIG???
// c'est étrange qu'il faille mettre cette valeur à cet endroit, mais ça marche quand même
// const APP_CONFIG = const OpaqueToken('app.config');


@Component(
  selector: 'todo-list',
  styleUrls: const ['todo_list_component.css'],
  templateUrl: 'todo_list_component.html',
  directives: const [
    CORE_DIRECTIVES,
    materialDirectives,
    TodoDetailComponent,
  ],
  // providers: const [TodoListService],
  // je peux essayer de supprimer ce provider le InMemoryData car il est utilisé dans le parent... ? Bon... on dirait que ça marche...
  // providers: const [InMemoryData
                    // ,const Provider(APP_CONFIG, useFactory:tafConfigFactory)
  //],
)


class TodoListComponent implements OnInit {
  //final TodoListService todoListService;
  //final InMemoryData inMemoryData;
  List<Todo> todoItems = [];
  Todo selectedTodo;
  String newTodo = '';
  final Router _router;
  final Location _location;
  final RouteParams _routeParams;

  String tag;

  final String user = "PBD";
  //final String user;

  final nformat = new NumberFormat("000000");
  final dformat = new DateFormat('yyyy-MM-dd HH:mm:ss');

  //TodoListComponent(this.inMemoryData);
  //TodoListComponent(@Inject(APP_CONFIG) AppConfig config, this._router):user = config.user;
  TodoListComponent(this._router, this._location, this._routeParams);

  @override
  void ngOnInit() {
    //todoItems = await todoListService.getTodoItems();
    tag = _routeParams.get('tag');
    if (tag == "all") todoItems = InMemoryDataService.giveAll();
    else if ((tag != null) && (tag != "")) todoItems = InMemoryDataService.giveAllByTag(tag);
    else todoItems = InMemoryDataService.giveAll();
    print("List onInit..." + todoItems.length.toString());
  }

  void add() {
    var now = new DateTime.now();
    var id = user+nformat.format(InMemoryDataService.giveMaxTodoId()+1);
    List<String> decodeList = Converter.decodeNewTodo(newTodo);
    var color = 0;
    if (decodeList[2] != "") color = Converter.stringToModuloIndex(decodeList[2], 80) + 1;

    InMemoryDataService.insert(new Todo.fromJson({'id': id, 'dayhour': dformat.format(now), 'version': '',
                                                        'data': {'title':decodeList[0], 'description':decodeList[1], 'tag':decodeList[2], 'color':color}}));
    // plus besoin de d'ajouter le todoitem à la liste todoItems car il y a surement un binding automatique avec la ligne du dessus
    newTodo = '';
  }

  void remove(Todo todoItem) {
    // await todoListService.delete(todoItem.id);
    // await InMemoryDataService.clearById(todoItem.id);
    // plus besoin de retirer le todoitem à la liste todoItems car il y a surement un binding automatique avec la ligne du dessus
    // todoItems.remove(todoItem);
    // nouvelle stratégie = on va marquer l'item comme étant à supprimer et on ne va plus l'afficher
    todoItem.version = "DD";
    var now = new DateTime.now();
    todoItem.dayhour = dformat.format(now);
  }

  //=> todoItems.removeAt(index);
  /*
  void edit(Todo t) {
    selectedTodo = t;
  }
  */

  void gotoDetail(Todo todoItem) => _router.navigate([
    'Detail',
    {'id': todoItem.id}
  ]);

  void doneOnOff(Todo todoItem, bool checked) {
    print("doneOnOff... " + todoItem.id + " -> " + checked.toString());
    var now = new DateTime.now();
    todoItem.dayhour = dformat.format(now);
    todoItem.done = checked;
  }

  void goBack() => _location.back();


}
