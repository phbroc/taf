import 'package:angular2/angular2.dart';
import 'src/todo_list/todo.dart';
import 'dart:async';
import 'package:http/http.dart';
import 'dart:convert';


@Injectable()
class ServerDataService {
  final Client _http;
  // attention à l'encodage !
  static final _headers = {'Content-Type': 'application/json; charset=utf-8'};

  static const _apiUrl = 'api/server/synchro.php';

  static const _loginUrl = 'api/server/login.php';
  //static const _loginUrl = 'http://localhost/~philippe/taf/databaseTest/api/server/login11.php';

  static const _logoffUrl = 'api/server/logoff.php';
  //static const _logoffUrl = 'http://localhost/~philippe/taf/databaseTest/api/server/logoff7.php';
  static const _checkTokenUrl = 'api/server/checkToken.php';
  //static const _checkTokenUrl = 'http://localhost/~philippe/taf/databaseTest/api/server/checkToken.php';


  ServerDataService(this._http);

  Future<String> connect(String u, String p) async {
    // simple test en GET pour debugger
    /*
    try {
      print("calling server...");
      final response = await _http.get(_loginUrl);
      print("... " + response.body);
      Map jsonData = _extractData(response);
      if (jsonData['token'] != null) return jsonData['token'];
      else return null;
    } catch (e) {
      throw _handleError(e);
    }
    */
    // methode en POST

    try {
      print("login... " + u);
      final response = await _http.post(_loginUrl, headers: _headers,
          body: JSON.encode({
            'user': u,
            'pass': p
          }));
      print("response body... " + response.body);
      Map jsonData = _extractData(response);
      print("server response found... " + jsonData['token'].toString());
      return jsonData['token'];
    }
    catch (e) {
      throw _handleError(e);
    }


  }

  Future<String> disconnect(String u, String t) async {
    // test en GET
    /*
    try {
      print("logoff... " + u);
      final response = await _http.get(_logoffUrl);
      print("response body... " + response.body);
      Map jsonData = _extractData(response);
      print("server response found... " + jsonData['token']);
      if (jsonData['token'] != null) return jsonData['token'];
      else return "";
    }
    catch (e) {
      throw _handleError(e);
    }
    */
    // methode en POST

    try {
      print("logoff... " + u);
      final response = await _http.post(_logoffUrl, headers: _headers,
          body: JSON.encode({
            'user': u,
            'token': t
          }));
      print("response body... " + response.body);
      Map jsonData = _extractData(response);
      print("server response found... " + jsonData['token']);
      return jsonData['token'];
    }
    catch (e) {
      throw _handleError(e);
    }

  }

  Future<bool> checkToken(String u, String t) async {
    // simple test en GET pour debugger
    /*
      try {
      print("checkToken... " + t);
      final response = await _http.get(_checkTokenUrl);
      print("response body... " + response.body);
      Map jsonData = _extractData(response);
      print("server response found... " + jsonData['connected'].toString());
      return jsonData['connected'] == true;
    }
    catch (e) {
      throw _handleError(e);
    }

    */
    // methode en POST

    try {
      print("checkToken... " + t);
      final response = await _http.post(_checkTokenUrl, headers: _headers,
          body: JSON.encode({
            'user': u,
            'token': t
          }));
      print("response body... " + response.body);
      if (response.body.indexOf('Exception') == -1) {
        Map jsonData = _extractData(response);
        print("server response found... " + jsonData['connected'].toString());
        return jsonData['connected'] == true;
      }
      else {
        return false;
      }
    }
    catch (e) {
      throw _handleError(e);
    }

  }

  Future<List<Todo>> synchroTodoList(List<Todo> l, String dh, String u, String t) async {
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

    // essai d'un simple get (fonctionne dans l'éditeur avant de passer en prod)
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
      print("post... "); // + JSON.encode({'token':t,'user':u,'dayhour':dh,'data':todoPost}));
      final response = await _http.post(_apiUrl, headers: _headers, body: JSON.encode({'token':t,'user':u,'dayhour':dh,'data':todoPost}));
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