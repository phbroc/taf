class Todo {
  String id;
  String dayhour;
  String version;
  String title;
  String description;
  bool done;

  Todo(this.id, this.dayhour, this.version, this.title, this.description, this.done);

  factory Todo.fromJson(Map<String, dynamic> todo_js) {
    String _title;
    String _description;
    bool _done;
    if (todo_js['data'] != null) {
      if (todo_js['data']['title'] != null) _title = todo_js['data']['title']; else _title = "no title!";
      if (todo_js['data']['description'] != null) _description = todo_js['data']['description']; else _description = "";
      if (todo_js['data']['done'] != null) _done = todo_js['data']['done'] == true ? true : false; else _done = false;
    }
    return new Todo(todo_js['id'], todo_js['dayhour'], todo_js['version'], _title, _description, _done);
  }

  Map toJson() => {'id': id, 'dayhour': dayhour, 'version': version, 'data': {'title':title, 'description': description, 'done': done}};

}

// int _toInt(id) => id is int ? id : int.parse(id);