import 'package:angular/angular.dart';
import 'src/todo_list/todo.dart';
import 'src/tag_list/tag.dart';

@Injectable()
class InMemoryDataService {
  static List<Todo> _todoDb;
  static List<Tag> _tagLi;

  InMemoryDataService();

  static resetDb() {
    //_nextId = 1;
    _todoDb = <Todo>[];
    _tagLi = <Tag>[];
  }

  static void insert(Todo todoItem) {
    print("insert : " + todoItem.id);
    _todoDb.insert(0,todoItem);

    if (todoItem.tag != "")
    {
      Tag inlisttag = _tagLi.firstWhere((tagl) => tagl.tagName == todoItem.tag, orElse: () => null);
      Tag newtag = new Tag(todoItem.tag, todoItem.color);
      if (inlisttag == null) _tagLi.add(newtag);
    }
  }

  static void modify(Todo todoItemChanges) {
    var targetTodoItem = _todoDb.firstWhere((todoItem) => todoItem.id == todoItemChanges.id, orElse: () => null);
    if (targetTodoItem != null) {
      if (targetTodoItem.tag != todoItemChanges.tag)
      {
        Tag inlisttag = _tagLi.firstWhere((tagl) => tagl.tagName == todoItemChanges.tag, orElse: () => null);
        Tag newtag = new Tag(todoItemChanges.tag, todoItemChanges.color);
        if (inlisttag == null) _tagLi.add(newtag);

        // todo: eventuellement supprimer l'ancien tag si c'était le dernier avant modification
      }

      targetTodoItem.title = todoItemChanges.title;
      targetTodoItem.description = todoItemChanges.description;
      targetTodoItem.done = todoItemChanges.done;
      targetTodoItem.tag = todoItemChanges.tag;
      targetTodoItem.color = todoItemChanges.color;


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

    // todo: eventuellement supprimer l'ancien tag si c'était la suppression
  }

  static void startWithAll(List<Todo> todoItems) {
    _todoDb = todoItems;
    _tagLi = <Tag>[];
    Tag newtag;
    Tag inlisttag;

    _todoDb.forEach((todoItem) {
      inlisttag = _tagLi.firstWhere((tagl) => tagl.tagName == todoItem.tag, orElse: () => null);
      newtag = new Tag(todoItem.tag, todoItem.color);
      if (inlisttag == null) _tagLi.add(newtag);
    });
  }

  static List<Tag> giveListOfTags() {
    return _tagLi;
  }
}