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
  bool quick;
  bool crypto;



  Todo(this.id, this.dayhour, this.version, this.title, this.description, this.done, this.tag, this.color, this.end, this.priority, this.quick, this.crypto);

  factory Todo.fromJson(Map<String, dynamic> todo_js) {
    String _title;
    String _description;
    bool _done;
    String _tag;
    int _color;
    DateTime _end;
    int _priority;
    bool _quick;
    bool _crypto;

    if (todo_js['version'] == "XX") {
      // correspond à une demande de suppression, on n'a plus les infos title, description, done, mais une liste de tokens en retour
      _title = "to delete !";
      _description = "";
      _done = false;
      _color = 0;
      _end = null;
      _priority = 100;
      _quick = false;
      _crypto = false;
    }
    else if (todo_js['data'] != null) {
      if (todo_js['data']['title'] != null) _title = todo_js['data']['title']; else _title = "no title!";
      if (todo_js['data']['description'] != null) _description = todo_js['data']['description'].replaceAll(RegExp(r'\\n'), '\n'); else _description = "";
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
      if (todo_js['data']['quick'] != null) _quick = todo_js['data']['quick'] == true ? true : false; else _quick = false;
      if (todo_js['data']['crypto'] != null) _crypto = todo_js['data']['crypto'] == true ? true : false; else _crypto = false;
    }
    return Todo(todo_js['id'], todo_js['dayhour'], todo_js['version'], _title, _description, _done, _tag, _color, _end, _priority, _quick, _crypto);
  }

  Map toJson() {
    String d = description.replaceAll(RegExp(r'\n'), '\\n');
    return {'id':id, 'dayhour':dayhour, 'version':version, 'data':{'title':title, 'description':d, 'done':done, 'tag':tag, 'color':color, 'end':end.toString(), 'priority':priority, 'quick':quick, 'crypto':crypto}};
  }

}

// int _toInt(id) => id is int ? id : int.parse(id);