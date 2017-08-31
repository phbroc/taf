class Todo {
  String id;
  String dayhour;
  String version;
  String title;
  String description;

  Todo(this.id, this.dayhour, this.version, this.title, this.description);

  factory Todo.fromJson(Map<String, dynamic> todo_js) =>
    new Todo(todo_js['id'], todo_js['dayhour'], todo_js['version'], todo_js['data']['title'], todo_js['data']['description']);


  Map toJson() => {'id': id, 'dayhour': dayhour, 'version': version, 'data': {'title':title, 'description': description}};
}

// int _toInt(id) => id is int ? id : int.parse(id);