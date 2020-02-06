import 'package:angular/angular.dart';
import 'src/todo_list/todo.dart';
import 'dart:async';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'src/app_config.dart';

@Injectable()
class ServerDataService {
  // on initialise la propriété là, à la place de le faire dans le constructeur précédemment
  static final Client _http = Client();

  // attention à l'encodage !
  static final _headers = { 'Content-Type': 'application/json; charset=utf-8'};

  static String _serverUrl;
  static String _synchroUrl;
  static String _loginUrl;
  static String _logoffUrl;
  static String _checkTokenUrl;
  static final dformat = DateFormat('yyyy-MM-dd HH:mm:ss');

  //pas d'instantiation d'objet pour class injectable. ???
  //ServerDataService(this._http); en fait ça fonctionne quand même!

  ServerDataService(AppConfig config) {
    _serverUrl = config.apiEndpoint;
    _synchroUrl = _serverUrl + 'api/server/synchro.php';
    _loginUrl = _serverUrl + 'api/server/login.php';
    _logoffUrl = _serverUrl + 'api/server/logoff.php';
    _checkTokenUrl = _serverUrl + 'api/server/checkToken.php';
  }

  Future<String> connect(String u, String p) async {

    try {
      print("login... " + u);
      final response = await _http.post(_loginUrl, headers: _headers,
          body: jsonEncode({
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

    try {
      print("logoff... " + u);
      final response = await _http.post(_logoffUrl, headers: _headers,
          body: jsonEncode({
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

    try {
      print("checkToken... " + t);
      final response = await _http.post(_checkTokenUrl, headers: _headers,
          body: jsonEncode({
            'user': u,
            'token': t
          }));
      print("response body... " + response.body);
      if (response.body.indexOf('connected') != -1) {
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

  Future<List<Todo>> synchroTodoList(List<Todo> l, DateTime dh, String u, String t) async {
    List<Todo> retTodoItems = <Todo>[];
    // j'ai un doute sur le fait de passer les data dans une chaine de caractères... j'enlève ce code.
    /*
    String jsonData = '';
    var sb = StringBuffer();
    // List todoPost = [];
    sb.write('[');
    l.forEach((todoItem) {
      sb.write(todoItem.toJson().toString()+",");
      // todoPost.add(todoItem.toJson());
    });
    if (l.length > 0) jsonData = sb.toString().substring(0, sb.toString().length-1);
    else jsonData = '[';
    jsonData += ']';
    */
    try {
      print("post... " + l.length.toString()); //jsonEncode({'token':t,'user':u,'dayhour':dformat.format(dh),'data':l}));
      final response = await _http.post(_synchroUrl, headers: _headers, body: jsonEncode({'token':t,'user':u,'dayhour':dformat.format(dh),'data':l}));
      // print("response body... " + response.body);
      List jsonList = _extractData(response);
      print("server response found... " + jsonList.length.toString());

      if (jsonList.length == 1) {
        if (jsonList[0]['Exception'] != null) throw Exception(jsonList[0]['Exception']);
        else {
          retTodoItems.add(Todo.fromJson(jsonList[0]));
        }
      }
      else if (jsonList.length > 1) {
        for (var i = 0; i < jsonList.length; i++) {
          retTodoItems.add(Todo.fromJson(jsonList[i]));
        }
      }

      return retTodoItems;
    } catch (e) {
      print("Exception in synchroTodoList..."+e.toString());
      throw _handleError(e);
    }

  }

  dynamic _extractData(Response resp) => jsonDecode(resp.body);

  Exception _handleError(dynamic e) {
    print('Server error; cause: $e'); // for demo purposes only
    return Exception('Server error; cause: $e');
  }

}