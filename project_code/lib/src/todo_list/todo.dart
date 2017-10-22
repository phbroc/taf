class Todo {
  String id;
  String dayhour;
  String version;
  String title;
  String description;
  bool done;
  String tag;
  int color;


  Todo(this.id, this.dayhour, this.version, this.title, this.description, this.done, this.tag, this.color);

  factory Todo.fromJson(Map<String, dynamic> todo_js) {
    String _title;
    String _description;
    bool _done;
    String _tag;
    int _color;
    if (todo_js['version'] == "XX") {
      // correspond à une demande de suppression, on n'a plus les infos title, description, done, mais une liste de tokens en retour
      _title = "to delete !";
      _description = "";
      _done = false;
    }
    else if (todo_js['data'] != null) {
      if (todo_js['data']['title'] != null) _title = todo_js['data']['title']; else _title = "no title!";
      if (todo_js['data']['description'] != null) _description = todo_js['data']['description']; else _description = "";
      if (todo_js['data']['done'] != null) _done = todo_js['data']['done'] == true ? true : false; else _done = false;
      if (todo_js['data']['tag'] != null) _tag = todo_js['data']['tag']; else _tag = "";
      if (todo_js['data']['color'] != null) _color = todo_js['data']['color']; else _color = 0;
    }
    return new Todo(todo_js['id'], todo_js['dayhour'], todo_js['version'], _title, _description, _done, _tag, _color);
  }

  Map toJson() => {'id':id, 'dayhour':dayhour, 'version':version, 'data':{'title':title, 'description':description, 'done':done, 'tag':tag, 'color':color}};

}

// int _toInt(id) => id is int ? id : int.parse(id);