import 'package:angular2/angular2.dart';
import 'src/todo_list/todo.dart';
import 'dart:async';
import 'package:http/http.dart';
import 'dart:convert';


@Injectable()
class ServerDataService {
  final Client _http;
  static final _headers = {'Content-Type': 'application/json'};
  //static const _apiUrl = 'api/server'; // URL to web API
  //static const _apiUrl = 'api/server/test.json'; // URL to web API
  //static const _apiUrl = 'http://localhost/~philippe/taf/databaseTest/synchro4.php';
  //static const _apiUrl = 'http://localhost/~philippe/taf/databaseTest/synchro3.php';
  static const _apiUrl = 'api/server/synchro4.php';

  ServerDataService(this._http);

  Future<List<Todo>> synchroTodoList(List<Todo> l) async {
    List<Todo> retTodoItems = <Todo>[];
    //Todo td;
    String jsonData = '';
    var sb = new StringBuffer();
    List todoPost = [];
    sb.write('[');
    l.forEach((todoItem) {
      sb.write(JSON.encode(todoItem.toJson())+",");
      todoPost.add(todoItem.toJson());
    });
    if (l.length > 0) jsonData = sb.toString().substring(0, sb.toString().length-1);
    else jsonData = '[';
    jsonData += ']';

    // essai d'un simple get
    /*
    try {
      print("calling server...");
      final response = await _http.get(_apiUrl);

      List jsonList = _extractData(response);
      print("server response found... " + jsonList.length.toString());
      for(var i=0; i<jsonList.length; i++) {
        retTodoItems.add(new Todo.fromJson(jsonList[i]));
      }

      return retTodoItems;
    } catch (e) {
      throw _handleError(e);
    }
    */

    // essai d'un post
    try {
      print("post... " + JSON.encode({'data': todoPost}));
      final response = await _http.post(_apiUrl, headers: _headers, body: JSON.encode({'data': todoPost}));
      print("response body... " + response.body);
      List jsonList = _extractData(response);
      print("server response found... " + jsonList.length.toString());
      for(var i=0; i<jsonList.length; i++) {
        retTodoItems.add(new Todo.fromJson(jsonList[i]));
      }

      return retTodoItems;
    } catch (e) {
      throw _handleError(e);
    }
  }

  dynamic _extractData(Response resp) => JSON.decode(resp.body);

  Exception _handleError(dynamic e) {
    print(e); // for demo purposes only
    return new Exception('Server error; cause: $e');
  }

}