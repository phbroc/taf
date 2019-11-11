
class Cryptographie {

  static String findStringToEncrypt(String s) {
    String retStr = "";
    RegExp openStr = RegExp(r"(\][a-zA-Z0-9]+\[)");
    Match matches = openStr.firstMatch(s);
    if (matches != null) {
      retStr = matches.group(0);
    }
    return retStr;
  }





}