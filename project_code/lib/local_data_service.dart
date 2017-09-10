import 'dart:async';
import 'dart:html';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'src/todo_list/todo.dart';

import 'package:angular2/core.dart';

@Injectable()
class LocalDataService {
  //List<To do> to doList = <To do>[];
  Storage localStorage = window.localStorage;

  final nformat = new NumberFormat("000000");
  final dformat = new DateFormat('yyyy-MM-dd HH:mm:ss');

  Future<List<Todo>> getTodoList() async {
    print("get local... "); // + todoList.length.toString());
    List<Todo> todoList = <Todo>[];
    //if (todoList.length > 0) return todoList;
    //else {
      var jsonString = localStorage['tafJSON'];
      if (jsonString != null) {
        print("json... " + jsonString);
        List jsonList = JSON.decode(jsonString);
        //print(jsonList[0]);
        //print(jsonList[0]['id']);
        //print(jsonList[0]['data']['title']);

        for(var i=0; i<jsonList.length; i++) {
          //print(jsonList[i]);
          //todoList.add(new Todo(jsonList[i]['id'], jsonList[i]['dayhour'], jsonList[i]['version'], jsonList[i]['data']['title'], jsonList[i]['data']['description'],false));
          todoList.add(new Todo.fromJson(jsonList[i]));
        }


        return todoList;
      }
      else
      {
        print("empty local storage");
        return todoList;
      }
    //}
  }

  void saveLocal(List<Todo> l) {
    String jsonData = '';
    var sb = new StringBuffer();
    sb.write('[');
    l.forEach((todoItem) {
      //sb.write('{"id":"'+todoItem.id+'", "dayhour":"'+todoItem.dayhour+'", "version":"'+todoItem.version+'", "data":{"title":"'+todoItem.title+'", "description":"'+todoItem.description+'"}},');
      sb.write(JSON.encode(todoItem.toJson())+",");
    });
    if (l.length > 0) jsonData = sb.toString().substring(0, sb.toString().length-1);
    else jsonData = '[';
    jsonData += ']';
    localStorage['tafJSON'] = jsonData;
    print("serialisation : " + jsonData);
  }

  void removeLocal() {
    localStorage['tafJSON'] = "";
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

  void saveDayhourSync(String u, String dh) {
    String key = 'tafDH'+u;
    localStorage[key] = dh;
  }

  String getDayhourSync(String u) {
    String key = 'tafDH'+u;
    return localStorage[key];
  }
}
