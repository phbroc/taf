import 'package:angular2/angular2.dart';
import 'src/todo_list/todo.dart';

@Injectable()
class InMemoryDataService {
  static List<Todo> _todoDb;
  //static int _nextId;

  InMemoryDataService();

  static resetDb() {
    //_nextId = 1;
    _todoDb = <Todo>[];
  }

  static void insert(Todo todoItem) {
    print("insert : " + todoItem.id);
    _todoDb.insert(0,todoItem);
  }

  static void modify(Todo todoItemChanges) {
    var targetTodoItem = _todoDb.firstWhere((todoItem) => todoItem.id == todoItemChanges.id, orElse: () => null);
    if (targetTodoItem != null) {
      targetTodoItem.title = todoItemChanges.title;
    }
  }

  static Todo giveById(String id) {
    return _todoDb.firstWhere((todoItem) => todoItem.id == id, orElse: () => null);
  }

  static List<Todo> giveAll() {
    return _todoDb;
  }

  static List<Todo> giveAllSince(DateTime d) {
    List<Todo> filteredTodo = [];
    print("giveAllSince " + d.toString() + "...");
    _todoDb.forEach((todoItem) {
      if (d.isBefore(DateTime.parse(todoItem.dayhour))) filteredTodo.add(todoItem);
    });
    print("... length : " + filteredTodo.length.toString());
    return filteredTodo;
  }

  static void clearById(String id) {
    print("DB length : " + _todoDb.length.toString() + ", clearById : " + id);
    _todoDb.removeWhere((todoItem) => todoItem.id == id);
    print("new length : " + _todoDb.length.toString());
  }

  static void startWithAll(List<Todo> todoItems) {
    _todoDb = todoItems;
  }
}