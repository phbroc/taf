import '../commons.dart';

class Tag {
  String name;
  int color;

  Tag (this.name, this.color);

  factory Tag.fromJson(Map<String, dynamic> tag) => Tag(tag['name']!, tag['color']);

  Map toJson() => {'name': name, 'color': color};

  void giveMeColor() {
    color = Commons.stringToModuloIndex(name, 80);
  }
}