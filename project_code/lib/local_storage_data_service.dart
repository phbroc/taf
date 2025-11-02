import 'dart:convert';
import 'dart:html';
import 'dart:math';
import 'src/toknow/toknow.dart';

class LocalStorageDataService {
  static Storage localStorage = window.localStorage;
  static late String localName;

  static void setup(String n) {
    localName = n;
  }

  static void saveToknows(List<Toknow> toknows) async {
    if (toknows.isNotEmpty) {
      var tList = [];
      for (Toknow t in toknows) {
        tList.add(t.toJson());
      }
      var jsonData = json.encode({'data': tList});
      localStorage['tk_$localName'] = jsonData;
    }
  }

  static Future<List<Toknow>> loadToknows() async {
    List<Toknow> toknows = <Toknow>[];
    var jsonData;
    jsonData = localStorage['tk_$localName'];

    if (jsonData != null) {
      List jsonList = jsonDecode(jsonData)['data'];
      for(var i=0; i<jsonList.length; i++) {
        toknows.add(Toknow.fromJson(jsonList[i]));
      }
    }
    return toknows;
  }

  /*
  static void saveToken(String t) {
    var jsonData = json.encode({'data': t});
    localStorage['bt_$localName'] = jsonData;
  }

  static String? getToken() {
    var jsonData;
    jsonData = localStorage['bt_$localName'];
    if (jsonData != null) {
      return jsonDecode(jsonData)['data'];
    }
    else {
      return null;
    }
  }
  */

  static void saveUser(String u, String t, String e) {
    var jsonData = json.encode({'user': u, 'token': t, 'email': e});
    localStorage['us_$localName'] = jsonData;
  }

  static Map<String, String>? getUser() {
    var jsonData;
    jsonData = localStorage['us_$localName'];
    if (jsonData != null) {
      final userData = <String, String>{'user': jsonDecode(jsonData)['user'],
        'token': jsonDecode(jsonData)['token'],
        'email': jsonDecode(jsonData)['email']
      };
      return Map.fromEntries(userData.entries);
    }
    else {
      return null;
    }
  }

  static void saveDayHourSync(String dh) {
    var jsonData = json.encode({'data': dh});
    localStorage['dh_$localName'] = jsonData;
  }

  static String? getDayHourSync() {
    var jsonData;
    jsonData = localStorage['dh_$localName'];
    if (jsonData != null) {
      return jsonDecode(jsonData)['data'];
    }
    else {
      return null;
    }
  }

}