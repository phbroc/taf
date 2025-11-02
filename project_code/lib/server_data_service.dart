import 'dart:async';
import 'package:http/http.dart';
import 'dart:convert';
import 'src/toknow/toknow.dart';


class ServerDataService {
  static final Client _http = Client();
  static late String _apiUrl;
  static late String _userUrl;
  static late String _toknowUrl;

  static void setup(String api, String user, String toknow) {
    _apiUrl = api;
    _userUrl = "$api/$user";
    _toknowUrl = "$api/$toknow";
  }

  static Future<Response> connect(String user, String password) async {
    // TODO encrypt password before sending.
    try {
      final responseC = await _http.post(
          Uri.parse(_userUrl),
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'Authorization': 'Bearer Null'
          },
          body: jsonEncode({
            'user': user,
            'password': password
          }));
      return responseC;
    }
    catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Response> changePassword(String user, String password, String newPassword, String token) async {
    try {
      final responseC = await _http.post(
          Uri.parse(_userUrl),
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'Authorization': 'Bearer $token'
          },
          body: jsonEncode({
            'user': user,
            'password': password,
            'newPassword': newPassword
          }));
      return responseC;
    }
    catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Response> disconnect(String u, String t) async {
    try {
      final responseD = await _http.post(
          Uri.parse(_userUrl),
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'Authorization': 'Bearer $t'
          },
          body: jsonEncode({
            'user': u
          }));
      return responseD;
    }
    catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Response> checkToken(String t) async {
    try {
      final responseU = await _http.get(
          Uri.parse(_userUrl),
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'Authorization': 'Bearer $t'
          });
      return responseU;
    }
    catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Response> synchroToknowList(List<Toknow> l, DateTime dh, String t) async {
    try {
      var tList = [];
      for (Toknow t in l) {
        tList.add(t.toJson());
      }
      final responseT = await _http.post(
          Uri.parse(_toknowUrl),
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'Authorization': 'Bearer $t'
          },
          body: jsonEncode({
            'dayhour': dh.toIso8601String(),
            'toknows': tList
          }));
      return responseT;
    }
    catch (e) {
      throw _handleError(e);
    }
  }

  static Exception _handleError(dynamic e) {
    print(e); // for demo purposes only
    return Exception('Server error; cause: $e');
  }

}