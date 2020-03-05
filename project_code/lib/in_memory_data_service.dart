import 'package:angular/angular.dart';
import 'src/todo_list/todo.dart';
import 'src/tag_list/tag.dart';

@Injectable()
class InMemoryDataService {
  static List<Todo> _todoDb;
  static List<Tag> _tagLi;
  static String _cryptoKey;

  InMemoryDataService();

  static resetDb() {
    //_nextId = 1;
    _todoDb = <Todo>[];
    _tagLi = <Tag>[];
  }

  static void insert(Todo todoItem) {
    //print("insert : " + todoItem.id);
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
      targetTodoItem.end = todoItemChanges.end;
      targetTodoItem.priority = todoItemChanges.priority;
      targetTodoItem.quick = todoItemChanges.quick;
      targetTodoItem.crypto = todoItemChanges.crypto;
    }
  }

  static Todo giveById(String id) {
    return _todoDb.firstWhere((todoItem) => todoItem.id == id, orElse: () => null);
  }

  static List<Todo> giveAll() {
    return _todoDb;
  }

  static int todoTagListLength(String t) {
    return giveAllByTag(t,0).length;
  }

  static List<Todo> giveAllSince(DateTime d) {
    List<Todo> filteredTodo = [];
    //print("giveAllSince " + d.toString() + "...");
    _todoDb.forEach((todoItem) {
      if (d.isBefore(DateTime.parse(todoItem.dayhour))) filteredTodo.add(todoItem);
    });
    //print("... length : " + filteredTodo.length.toString());
    return filteredTodo;
  }

  static List<Todo> giveAllByTag(String t, int page) {
    List<Todo> filteredTodo = [];
    //print("giveAllBy " + t + "...");
    _todoDb.forEach((todoItem) {
      if (todoItem.tag == t) filteredTodo.add(todoItem);
    });
    //print("... length : " + filteredTodo.length.toString());
    if (page>0) {
      if (filteredTodo.length >= page*10) return filteredTodo.sublist((page-1)*10,page*10);
      else if (filteredTodo.length >= (page-1)*10) return filteredTodo.sublist((page-1)*10);
    }
    else return filteredTodo;
  }

  static void clearById(String id) {
    //print("DB length : " + _todoDb.length.toString() + ", clearById : " + id);
    _todoDb.removeWhere((todoItem) => todoItem.id == id);
    //print("new length : " + _todoDb.length.toString());

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

  static void updateTagList(Tag t) {
    if (t != null)
    {
      Tag inlisttag = _tagLi.firstWhere((tagl) => tagl.tagName == t.tagName, orElse: () => null);
      if (inlisttag == null)
        {
          _tagLi.add(t);
        }
    }
  }

  static int giveMaxTodoId() {
    int maxId = 0;
    int fetchId = 0;
    String idStr = "";
    _todoDb.forEach((todoItem) {
      idStr = todoItem.id;
      //print("add search next id..." + idStr);
      fetchId = int.parse(idStr.substring(idStr.indexOf('0')));
      if (fetchId > maxId) maxId=fetchId;}
    );
    return maxId;
  }

  static List<Todo> giveWeekTodo() {
    //print("giveWeekTodo...");
    List<Todo> weekTodo = [];
    DateTime now = new DateTime.now();
    int today = now.weekday;
    DateTime nextMonday = now.add(new Duration(days: 8-today));
    DateTime lastSunday = now.subtract(new Duration(days: today-0));
    DateTime weekStarts = new DateTime(lastSunday.year, lastSunday.month, lastSunday.day, 23, 59, 59);
    DateTime weekEnds = new DateTime(nextMonday.year, nextMonday.month, nextMonday.day, 0, 0, 0);
    // print("starts:"+weekStarts.toString()+" ends:"+weekEnds.toString());

    _todoDb.forEach((todoItem) {
      if (todoItem.end != null) {
        // print("todo "+todoItem.id+" ends "+todoItem.end.toString());
        if ((todoItem.end.isAfter(weekStarts)) && (todoItem.end.isBefore(weekEnds))) {
          weekTodo.add(todoItem);
          // print("week todo added");
        }
      }
    });


    return weekTodo;
  }

  static void setCryptoKey(String ck) {
    if (ck != null) _cryptoKey = ck.trim();
    else _cryptoKey = "";
    if (_cryptoKey.length == 0) _cryptoKey = null;
  }

  static String getCryptoKey() {
    return _cryptoKey;
  }
}