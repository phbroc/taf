// Copyright (c) 2017, philippe. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:angular2/angular2.dart';
import 'package:angular2/router.dart';
import 'package:angular_components/angular_components.dart';
import 'package:intl/intl.dart';

//import 'package:taf/src/app_config.dart';

import 'todo.dart';
//import 'todo_list_service.dart';
import 'package:taf/in_memory_data.dart';
import 'todo_detail_component.dart';

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

  final String user = "PBD";
  //final String user;

  final nformat = new NumberFormat("000000");
  final dformat = new DateFormat('yyyy-MM-dd HH:mm:ss');

  //TodoListComponent(this.inMemoryData);
  //TodoListComponent(@Inject(APP_CONFIG) AppConfig config, this._router):user = config.user;
  TodoListComponent(this._router);

  @override
  Future<Null> ngOnInit() async {
    //todoItems = await todoListService.getTodoItems();
    todoItems = await InMemoryData.giveAll();
  }

  Future<Null> add() async {
    int nextId = 0;
    int fetchId = 0;
    String idStr = "";
    todoItems.forEach((todoItem) {
      idStr = todoItem.id;
      print("add search next id..." + idStr);
      fetchId = int.parse(idStr.substring(idStr.indexOf('0')));
      if (fetchId > nextId) nextId=fetchId;}
    );
    //todoItems.add(new Todo(nextId+1, newTodo));
    //todoItems.add(await todoListService.create(newTodo));
    var now = new DateTime.now();
    var id = user+nformat.format(nextId+1);
    await InMemoryData.add(new Todo(id, dformat.format(now), "", newTodo, ""));
    // plus besoin de d'ajouter le todoitem à la liste todoItems car il y a surement un binding automatique avec la ligne du dessus
    newTodo = '';
  }

  Future<Null> remove(Todo todoItem) async {
    //await todoListService.delete(todoItem.id);
    await InMemoryData.clearById(todoItem.id);
    // plus besoin de retirer le todoitem à la liste todoItems car il y a surement un binding automatique avec la ligne du dessus
    //todoItems.remove(todoItem);
  }
  //=> todoItems.removeAt(index);

  void edit(Todo t) {
    selectedTodo = t;
  }

  Future<Null> gotoDetail(Todo t) => _router.navigate([
    'Detail',
    {'id': t.id}
  ]);

  void onReorder(ReorderEvent e) =>
      todoItems.insert(e.destIndex, todoItems.removeAt(e.sourceIndex));

}
