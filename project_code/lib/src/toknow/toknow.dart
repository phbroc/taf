class Toknow {
  String id;
  DateTime? dayhour;
  String version;
  String title;
  String? description;
  bool done;
  String tag;
  int color;
  DateTime? end;
  int priority;
  bool quick;
  bool crypto;


  Toknow(this.id, this.dayhour, this.version, this.title, this.description,
      this.done, this.tag, this.color, this.end, this.priority, this.quick, this.crypto);

  factory Toknow.fromJson(Map<String, dynamic> toknow) {
    String? tDesc = toknow['description'];
    late DateTime? tEnd;
    late DateTime? tDayh;
    if (toknow['dayhour'] != null) tDayh = DateTime.parse(toknow['dayhour']);
    else {
      tDayh = null;
    }
    if (toknow['end'] != null) tEnd = DateTime.parse(toknow['end']);
    else {
      tEnd = null;
    }
    return Toknow(
        toknow['id'],
        tDayh,
        toknow['version'],
        toknow['title'],
        tDesc,
        toknow['done'],
        toknow['tag'],
        toknow['color'],
        tEnd,
        toknow['priority'],
        toknow['quick'],
        toknow['crypto'],
    );
  }

  Map toJson() => {
    'id': id,
    'dayhour': dayhour?.toIso8601String(),
    'version': version,
    'title': title,
    'description': description,
    'done': done,
    'tag': tag,
    'color': color,
    'end': end?.toIso8601String(),
    'priority': priority,
    'quick': quick,
    'crypto': crypto
  };
}