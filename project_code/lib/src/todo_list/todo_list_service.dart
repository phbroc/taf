import 'dart:async';
import 'dart:convert';

import 'package:angular2/angular2.dart';
import 'package:http/http.dart';

import 'todo.dart';

import 'package:angular2/core.dart';

/// Mock service emulating access to a to-do list stored on a server.
@Injectable()
class TodoListService {
  static final _headers = {'Content-Type': 'application/json'};
  static const _todoItemsUrl = 'api/todoitems'; // URL to web API

  final Client _http;

  TodoListService(this._http);

  Future<List<Todo>> getTodoItems() async {
    try {
      final response = await _http.get(_todoItemsUrl);
      //print(response.body.toString());
      final todoItems = _extractData(response)
          .map((value) => new Todo.fromJson(value))
          .toList();
      return todoItems;
    } catch (e) {
      throw _handleError(e);
    }
  }

  dynamic _extractData(Response resp) => JSON.decode(resp.body)['data'];

  Exception _handleError(dynamic e) {
    print(e); // for demo purposes only
    return new Exception('Server error; cause: $e');
  }

  Future<Todo> create(String title) async {
    try {
      final response = await _http.post(_todoItemsUrl,
          headers: _headers, body: JSON.encode({'title': title}));
      return new Todo.fromJson(_extractData(response));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Null> delete(int id) async {
    try {
      final url = '$_todoItemsUrl/$id';
      await _http.delete(url, headers: _headers);
    } catch (e) {
      throw _handleError(e);
    }
  }


}