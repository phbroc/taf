import 'dart:async';
import 'package:http/http.dart';
import 'dart:convert';
import 'src/toknow/toknow.dart';


class ServerDataService {
  static final Client _http = Client();
  static late String _apiUrl;
  static late String _authAltHeader;
  static late String _authAltProcess;
  static late String _userUrl;
  static late String _toknowUrl;

  static void setup(String api, String authAltHeader, String authAltProcess, String user, String toknow) {
    _apiUrl = api;
    _userUrl = "$api/$user";
    _toknowUrl = "$api/$toknow";
    _authAltHeader = authAltHeader;
    _authAltProcess = authAltProcess;
  }

  static Future<Response> connect(String user, String password) async {
    // TODO encrypt password before sending.
    try {
      final responseC = await _http.post(
          Uri.parse(_userUrl),
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'Authorization': 'Bearer Null',
            _authAltHeader: '${_authAltProcess}Null',
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
            'Authorization': 'Bearer $token',
            _authAltHeader: '${_authAltProcess}$token'
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

  static Future<Response> disconnect(String user, String token) async {
    try {
      final responseD = await _http.post(
          Uri.parse(_userUrl),
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'Authorization': 'Bearer $token',
            _authAltHeader: '${_authAltProcess}$token'
          },
          body: jsonEncode({
            'user': user
          }));
      return responseD;
    }
    catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Response> checkToken(String token) async {
    try {
      final responseU = await _http.get(
          Uri.parse(_userUrl),
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'Authorization': 'Bearer $token',
            _authAltHeader: '${_authAltProcess}$token'
          });
      return responseU;
    }
    catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Response> synchroToknowList(List<Toknow> toknows, DateTime dayhour, String token) async {
    try {
      var tList = [];
      for (Toknow t in toknows) {
        tList.add(t.toJson());
      }
      final responseT = await _http.post(
          Uri.parse(_toknowUrl),
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'Authorization': 'Bearer $token',
            _authAltHeader: '${_authAltProcess}$token'
          },
          body: jsonEncode({
            'dayhour': dayhour.toIso8601String(),
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