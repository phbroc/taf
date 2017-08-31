import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:angular2/angular2.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';

//import 'src/app_config.dart';
import 'src/todo_list/todo.dart';

// extends MockClient est requis pour pouvoir écrire InMemoryDataService() : super(_handler);

// c'est étrange qu'il faille mettre cette valeur à cet endroit, mais ça marche quand même
//const APP_CONFIG = const OpaqueToken('app.config');

@Injectable()
class InMemoryDataService extends MockClient {
  static final _initialTodoItems = [
    {'id': 1, 'title': 'TAF n1'},
    {'id': 2, 'title': 'TAF n2'}
  ];

  static List<Todo> _todoDb;
  static int _nextId;

  static final nformat = new NumberFormat("000000");
  static final dformat = new DateFormat('yyyy-MM-dd HH:mm:ss');

  //final user;

  static Future<Response> _handler(Request request) async {
    var now = new DateTime.now();
    if (_todoDb == null) resetDb();
    var data;
    switch (request.method) {
      case 'GET':
        final id = request.url.pathSegments.last;
        if (id != null) {
          data = _todoDb
              .firstWhere((todoItem) => todoItem.id == id); // throws if no match
        } else {
          String prefix = request.url.queryParameters['title'] ?? '';
          final regExp = new RegExp(prefix, caseSensitive: false);
          data = _todoDb.where((todoItem) => todoItem.title.contains(regExp)).toList();
        }
        break;
      case 'POST':
        var title = JSON.decode(request.body)['title'];
        var newTodoItem = new Todo(nformat.format(_nextId++), dformat.format(now), "", title, "");
        _todoDb.add(newTodoItem);
        data = newTodoItem;
        break;
      case 'PUT':
        var todoItemChanges = new Todo.fromJson(JSON.decode(request.body));
        var targetTodoItem = _todoDb.firstWhere((todoItem) => todoItem.id == todoItemChanges.id);
        targetTodoItem.title = todoItemChanges.title;
        data = targetTodoItem;
        break;
      case 'DELETE':
        var id = int.parse(request.url.pathSegments.last);
        _todoDb.removeWhere((todoItem) => todoItem.id == id);
        // No data, so leave it as null.
        break;
      default:
        throw 'Unimplemented HTTP method ${request.method}';
    }
    return new Response(JSON.encode({'data': data}), 200,
        headers: {'content-type': 'application/json'});
  }

  static resetDb() {
    // pour le moment on fait quand même un mock de taf en dur...
    // print("resetDb()...");
    // _todoDb = _initialTodoItems.map((json) => new Todo.fromJson(json)).toList();
    // _nextId = _todoDb.map((todoItem) => todoItem.id).fold(0, max) + 1;
    _nextId = 1;
    _todoDb = [];
  }

  //InMemoryDataService(@Inject(APP_CONFIG) AppConfig config) : user = config.user, super(_handler);
  InMemoryDataService() : super(_handler);
}