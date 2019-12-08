import 'dart:async';
import 'dart:html';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'src/todo_list/todo.dart';

import 'package:angular/core.dart';

@Injectable()
class LocalDataService {
  //List<To do> to doList = <To do>[];
  Storage localStorage = window.localStorage;

  final nformat = NumberFormat("000000");
  final dformat = DateFormat('yyyy-MM-dd HH:mm:ss');

  List<Todo> getTodoList(String u) {
    String key = 'tafJSON'+u;
    print("get local... "); // + todoList.length.toString());
    List<Todo> todoList = <Todo>[];
    var jsonString = localStorage[key];
    if ((jsonString != null) && (jsonString != "")) {
        print("json... " + jsonString.length.toString() + " chars.");
        // print(jsonString);
        List jsonList = jsonDecode(jsonString);

        for(var i=0; i<jsonList.length; i++) {
          todoList.add(Todo.fromJson(jsonList[i]));
        }

        return todoList;
    }
    else {
        print("empty local storage");
        saveDayhourSync(u, null);
        return todoList;
    }
  }

  void saveTodoList(List<Todo> l, String u) {
    String jsonData = '';
    String key = 'tafJSON'+u;
    var sb = StringBuffer();
    sb.write('[');
    l.forEach((todoItem) {
      sb.write(jsonEncode(todoItem.toJson())+",");
    });
    if (l.length > 0) jsonData = sb.toString().substring(0, sb.toString().length-1);
    else jsonData = '[';
    jsonData += ']';
    localStorage[key] = jsonData;
    print("local serialisation " + l.length.toString() + " todoItems.");
  }

  void removeTodoList(String u) {
    String key = 'tafJSON'+u;
    localStorage[key] = "";
    key = 'tafJSONtemp1'+u;
    localStorage[key] = "";
    key = 'tafJSONtemp2'+u;
    localStorage[key] = "";
    saveDayhourSync(u, null);
  }

  void saveToken(String u, String t) {
    String key = 'tafTOKEN'+u;
    localStorage[key] = t;
  }

  String getToken(String u) {
    String key = 'tafTOKEN'+u;
    return localStorage[key];
  }

  void removeToken(String u) {
    String key = 'tafTOKEN'+u;
    localStorage[key] = "";
  }

  void saveDayhourSync(String u, DateTime dh) {
    String key = 'tafDH'+u;
    if (dh == null) {
      localStorage[key] = "";
    }
    else localStorage[key] = dformat.format(dh);
  }

  DateTime getDayhourSync(String u) {
    String key = 'tafDH'+u;
    if ((localStorage[key] != "") && (localStorage[key] != null)) return DateTime.parse(localStorage[key]);
    else return null;
  }

  void saveTempTodo1(Todo t, String u) {
    String jsonData = jsonEncode(t.toJson());
    String key = 'tafJSONtemp1'+u;
    localStorage[key] = jsonData;
    print("local serialisation tempTodo1.");
  }

  Todo getTempTodo1(String u) {
    String key = 'tafJSONtemp1'+u;
    if ((localStorage[key] != "") && (localStorage[key] != null)) return Todo.fromJson(jsonDecode(localStorage[key]));
    else return null;
  }

  void saveTempTodo2(Todo t, String u) {
    String jsonData = jsonEncode(t.toJson());
    String key = 'tafJSONtemp2'+u;
    localStorage[key] = jsonData;
    print("local serialisation tempTodo2.");
  }

  Todo getTempTodo2(String u) {
    String key = 'tafJSONtemp2'+u;
    if ((localStorage[key] != "") && (localStorage[key] != null)) return Todo.fromJson(jsonDecode(localStorage[key]));
    else return null;
  }
}
