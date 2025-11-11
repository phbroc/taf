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

  static void saveToknows(List<Toknow> toknows) {
    if (toknows.isNotEmpty) {
      var tList = [];
      for (Toknow t in toknows) {
        tList.add(t.toJson());
      }
      var jsonData = json.encode({'data': tList});
      localStorage['tk_$localName'] = jsonData;
    }
  }

  static List<Toknow> loadToknows() {
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

  static void resetToknows() {
    var jsonData = json.encode({'data': []});
    localStorage['tk_$localName'] = jsonData;
  }

  static void saveUser(String u, String t, String e) {
    var jsonData = json.encode({'user': u, 'token': t, 'email': e});
    localStorage['us_$localName'] = jsonData;
  }

  static void resetUser() {
    var jsonData = json.encode({'user': null, 'token': null, 'email': null});
    localStorage['us_$localName'] = jsonData;
  }

  static Map<String, String?> getUser() {
    var jsonData;
    jsonData = localStorage['us_$localName'];
    if (jsonData != null) {
      final userData = <String, String?>{'user': jsonDecode(jsonData)['user'],
        'token': jsonDecode(jsonData)['token'],
        'email': jsonDecode(jsonData)['email']
      };
      return Map.fromEntries(userData.entries);
    }
    else {
      return {'user': null,
        'token': null,
        'email': null
      };
    }
  }

  static void saveDayHourSync(String dh) {
    var jsonData = json.encode({'data': dh});
    localStorage['dh_$localName'] = jsonData;
  }

  static void resetDayHourSync() {
    //final DateTime resetDate = DateTime(2025, 1, 1);
    var jsonData = json.encode({'data': null}); //resetDate.toIso8601String()});
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