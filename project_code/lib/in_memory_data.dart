import 'package:angular2/angular2.dart';
import 'src/todo_list/todo.dart';

@Injectable()
class InMemoryData {
  static List<Todo> _todoDb;
  //static int _nextId;

  InMemoryData();

  static resetDb() {
    //_nextId = 1;
    _todoDb = <Todo>[];
  }

  static void add(Todo todoItem) {
    _todoDb.add(todoItem);
  }

  static void modify(Todo todoItemChanges) {
    var targetTodoItem = _todoDb.firstWhere((todoItem) => todoItem.id == todoItemChanges.id);
    targetTodoItem.title = todoItemChanges.title;
  }

  static Todo giveById(String id) {
    return _todoDb.firstWhere((todoItem) => todoItem.id == id);
  }

  static List<Todo> giveAll() {
    return _todoDb;
  }

  static void clearById(String id) {
    _todoDb.removeWhere((todoItem) => todoItem.id == id);
  }
}