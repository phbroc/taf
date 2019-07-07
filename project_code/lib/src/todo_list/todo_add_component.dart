// Copyright (c) 2019, philippe. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_router/angular_router.dart';
import '../route_paths.dart';
import 'todo.dart';
import '../../in_memory_data_service.dart';
import 'package:intl/intl.dart';
import '../utils/converter.dart';
import '../../event_bus.dart';
import 'dart:html';

@Component(
selector: 'todo-add',
styleUrls: ['todo_add_component.css'],
templateUrl: 'todo_add_component.html',
directives: [
  coreDirectives,
  MaterialFabComponent,
  MaterialInputComponent,
  MaterialIconComponent,
  materialInputDirectives,
],
)

class TodoAddComponent implements OnActivate {
  String newTodo = '';
  final nformat = NumberFormat("000000");
  final dformat = DateFormat('yyyy-MM-dd HH:mm:ss');
  final Router router;
  final EventBus eventBus;

  String tag;

  final String user = "PBD";


  TodoAddComponent(this.router, this.eventBus);

  @override
  void onActivate(_, RouterState current) {
    print("todoAddOnActivate... ");
    tag = getTag(current.parameters);
  }

  void add() {
    final RouterState current = router.current;
    print("add... "); // + current.parameters.toString());
    tag = getTag(current.parameters);
    var now = DateTime.now();
    var id = user+nformat.format(InMemoryDataService.giveMaxTodoId()+1);

    List<String> decodeList = Converter.decodeNewTodo(newTodo);
    String addTag = decodeList[2];
    var color = 0;
    if ((addTag != "") && addTag != null) color = Converter.stringToModuloIndex(addTag, 80) + 1;
    else if ((tag != "") && (tag != "all") && (tag != null)) {
      addTag = tag;
      color = Converter.stringToModuloIndex(addTag, 80) + 1;
    }
    else {
      addTag = "notag";
      color = Converter.stringToModuloIndex(addTag, 80) + 1;
    }

    InMemoryDataService.insert(Todo.fromJson({'id': id, 'dayhour': dformat.format(now), 'version': '',
      'data': {'title':decodeList[0], 'description':decodeList[1], 'tag':addTag, 'color':color, 'end':null, 'priority':100}}));
    // plus besoin de d'ajouter le todoitem à la liste todoItems car il y a surement un binding automatique avec la ligne du dessus
    // mais ça ne fonctionne pas si la page est filtrée par tag... je ne sais pas pourquoi

    // notification
    eventBus.onEventTodoAdd("todoadded");

    newTodo = '';
    // idee du dessous pour essayer de rafraichir le composant parent mais ça ne fonctionne pas.
    // router.navigate(RoutePaths.listtag.toUrl(parameters: {tagParam: '$tag'}));
  }


}