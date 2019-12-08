import 'dart:convert';

class Converter {
  static int stringToModuloIndex(String s, int r) {
    s = s.replaceAll(RegExp(r'é'), "e");
    s = s.replaceAll(RegExp(r'è'), "e");
    s = s.replaceAll(RegExp(r'ê'), "e");
    s = s.replaceAll(RegExp(r'à'), "a");
    s = s.replaceAll(RegExp(r'ô'), "o");
    s = s.replaceAll(RegExp(r'ï'), "i");
    //print("tag converter " + s);
    final encoder = AsciiEncoder();
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
    RegExp expTag = RegExp(r"(#[a-zA-Zéèêàôï]+)");
    print("...");
    //tag = expTag.stringMatch(s); cette syntaxe ne fonctionne pas
    Match matches = expTag.firstMatch(s);
    if (matches != null) {
      tag = matches.group(0);
      tag = tag.substring(1,tag.length);
    }

    s = s.replaceFirst(expTag, '');
    if (s == "") s = "title miss!";
    if (s.indexOf(",") != -1) {
      title = s.substring(0, s.indexOf(","));
      description = s.substring(s.indexOf(",")+1);
      if (description.indexOf(" ") == 0) description = description.substring(1);
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

  static String noLineBreak(String s) {
    s = s.replaceAll(RegExp(r'\r?\n|\r'), " ");
    return s;
  }
}