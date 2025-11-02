import '../in_memory_data_service.dart';
import '../server_data_service.dart';
import '../local_storage_data_service.dart';
import 'dart:convert';
import 'package:http/http.dart';

class Commons {
  static final _mockUrlUser = 'api/user';
  static InMemoryDataService _inMemoryDataService = InMemoryDataService();

  static dynamic _extractData(Response resp) => json.decode(resp.body)['data'];

  static Future<int> getLang() async {
    final response = await _inMemoryDataService.get(Uri.parse("api/lang"));
    String lang = json.decode(response.body)['data'];
    int langId = 0;
    switch (lang) {
      case 'FR' : langId = 0; break;
      case 'EN' : langId = 1; break;
      default : langId = 0; break;
    }
    return langId;
  }

  static Future<String?> getUserConnected() async {
    final responseU = await _inMemoryDataService.get(Uri.parse(_mockUrlUser));
    final userData = _extractData(responseU);
    String? token = userData['token'];
    if ((token != null) && (token != "")) {
      try {
        final responseU = await ServerDataService.checkToken(token);
        if (responseU.statusCode == 200) {
          Map jsonData = json.decode(responseU.body)['data'];
          if ((jsonData['user'] != null) && (jsonData['user'] != "")) {
            return jsonData['user'];
          }
          else {
            return null;
          }
        }
        else {
          Map errorData = json.decode(responseU.body)['data'];
          print("server error : ${errorData['error']}");
          return null;
        }
      } catch (e) {
        print("commons get user connected error");
        return null;
      }
    }
  }

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
    for (var ascCode in ascList) {sum += ascCode;}
    return sum%r;
  }
}