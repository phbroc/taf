class Todo {
  String id;
  String dayhour;
  String version;
  String title;
  String description;
  bool done;
  String tag;
  int color;
  DateTime end;
  int priority;


  Todo(this.id, this.dayhour, this.version, this.title, this.description, this.done, this.tag, this.color, this.end, this.priority);

  factory Todo.fromJson(Map<String, dynamic> todo_js) {
    String _title;
    String _description;
    bool _done;
    String _tag;
    int _color;
    DateTime _end;
    int _priority;
    if (todo_js['version'] == "XX") {
      // correspond à une demande de suppression, on n'a plus les infos title, description, done, mais une liste de tokens en retour
      _title = "to delete !";
      _description = "";
      _done = false;
      _color = 0;
      _end = null;
      _priority = 100;
    }
    else if (todo_js['data'] != null) {
      if (todo_js['data']['title'] != null) _title = todo_js['data']['title']; else _title = "no title!";
      if (todo_js['data']['description'] != null) _description = todo_js['data']['description'].replaceAll(new RegExp(r'\\n'), '\n'); else _description = "";
      if (todo_js['data']['done'] != null) _done = todo_js['data']['done'] == true ? true : false; else _done = false;
      if (todo_js['data']['tag'] != null) _tag = todo_js['data']['tag']; else _tag = "";
      if (todo_js['data']['color'] != null) _color = todo_js['data']['color']; else _color = 0;
      if ((todo_js['data']['end'] != null) && (todo_js['data']['end'] != "null")) {
        try {
          _end = DateTime.parse(todo_js['data']['end']);
        }
        catch (exception) {
          print("failed to parse date end "+todo_js['data']['end']);
          _end = null;
        }
      }
      else _end = null;
      if (todo_js['data']['priority'] != null) _priority = todo_js['data']['priority']; else _priority = 100;
    }
    return new Todo(todo_js['id'], todo_js['dayhour'], todo_js['version'], _title, _description, _done, _tag, _color, _end, _priority);
  }

  Map toJson() => {'id':id, 'dayhour':dayhour, 'version':version, 'data':{'title':title, 'description':description.replaceAll(new RegExp(r'\n'), '\\n'), 'done':done, 'tag':tag, 'color':color, 'end':end.toString(), 'priority':priority}};

}

// int _toInt(id) => id is int ? id : int.parse(id);