import 'dart:convert';

class Converter {
  static int stringToModuloIndex(String s, int r) {
    s = s.replaceAll(new RegExp(r'é'), "e");
    s = s.replaceAll(new RegExp(r'è'), "e");
    s = s.replaceAll(new RegExp(r'ê'), "e");
    s = s.replaceAll(new RegExp(r'à'), "a");
    s = s.replaceAll(new RegExp(r'ô'), "o");
    s = s.replaceAll(new RegExp(r'ï'), "i");
    //print("tag converter " + s);
    final encoder = new AsciiEncoder();
    int sum = 0;
    List<int> ascList = encoder.convert(s);
    ascList.forEach((ascCode) {sum += ascCode;});
    //.... return ....
    return sum%r;
  }

  static List<String> decodeNewTodo(String s) {
    var title = "";
    var description = "";
    var tag = "";
    List<String> retList = <String>[];
    RegExp expTag = new RegExp(r"('\w+')");
    print("...");
    //tag = expTag.stringMatch(s); cette syntaxe ne fonctionne pas
    Match matches = expTag.firstMatch(s);
    if (matches != null) {
      tag = matches.group(0);
      tag = tag.substring(1,tag.length-1);
    }

    s = s.replaceFirst(expTag, '');
    if (s == "") s = "title miss!";
    if (s.indexOf(";") != -1) {
      title = s.substring(0, s.indexOf(";"));
      description = s.substring(s.indexOf(";")+1);
    }
    else {
      title = s;
    }

    print(title + " " + description + " " + tag);
    //..... return .....
    retList.add(title);
    retList.add(description);
    retList.add(tag);
    return retList;
  }
}