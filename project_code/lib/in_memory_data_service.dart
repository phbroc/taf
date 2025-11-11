// Note: MockClient constructor API forces all InMemoryDataService members to be static.
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:math';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:intl/intl.dart';
import 'src/toknow/toknow.dart';
import 'src/tag/tag.dart';
import 'message_service.dart';

class InMemoryDataService extends MockClient {
  static String _user = '';
  static String _email = '';
  static String _lang = '';
  static String _key = '';
  static String _token = '';
  static late List<Toknow>  _toknowDb;
  static final numToknowFormat = NumberFormat("000000");
  static late List<Tag> _tagDb;


  static void resetDb() {
    _toknowDb = <Toknow>[];
    _tagDb = <Tag>[];
  }

  static void startWith(List<Toknow> toknows) {
    _toknowDb = toknows;
  }

  static void setUser(String u) {
    _user = u;
  }

  static int giveMaxToknowId(String u) {
    int maxId = 0;
    String idStr = '';
    String userStr = '';
    int fetchId = 0;
    for (var toknow in _toknowDb) {
      idStr = toknow.id;
      userStr = idStr.substring(0, 3);
      if (userStr == u) {
        fetchId = int.parse(idStr.substring(idStr.indexOf('0')));
        if (fetchId > maxId) maxId = fetchId;
      }
    }
    return maxId;
  }

  static void updateTagDb(String name) {
    if (name.isNotEmpty) {
      try {
        var t = _tagDb.firstWhere((tag) => tag.name == name);
      } catch (e) {
        Tag t = Tag(name, 0);
        t.giveMeColor();
        _tagDb.add(t);
      }
    }
  }

  static Future<Response> _handler(Request request) async {
    var data; // the response
    String last = request.url.pathSegments.last;
    String parent = request.url.pathSegments[1];
    String child = '';
    if (request.url.pathSegments.length > 2) {
      child = request.url.pathSegments[2];
    }

    switch (request.method) {
      case 'GET':
        if (parent == "pages") {
          if (child != '') {
            int maxPage = _toknowDb.where((toknow) => ((toknow.tag == child) && (toknow.version != "DD"))).length;
            int pages = max(1, (maxPage/10).ceil());
            data = json.encode({'data': pages});
          }
          else {
            data = json.encode({'data': 0});
          }
        }
        else if (parent == "key") {
          if (_key != '') {
            data = json.encode({'data': _key});
          }
          else {
            data = json.encode({'data': null});
          }
        }
        else if (parent == "user") {
          if (_user != '') {
            data = json.encode({'data': {'user':_user, 'token': _token, 'email': _email}});
          }
          else {
            data = json.encode({'data': '?'});
          }
        }
        else if (parent == "lang") {
          data = json.encode({'data': _lang});
        }
        else if (parent == "toknows") {
          if (parent == last) {
            data = json.encode({'data': _toknowDb.toList()});
          }
          else if (child == "tag") {
            String? name;
            if (request.url.pathSegments.length > 3) name = request.url.pathSegments[3];
            int? page = 0;
            if (name != last) page = int.tryParse(last);
            if ((page == null) || (page == 0)) page = 1;

            final tSearch = _toknowDb.where((toknow) => ((toknow.tag == name) && (toknow.version != "DD"))).toList();
            int i = 0;
            int pageStart = ((page-1)*10);
            int pageEnd = min(page*10, tSearch.length);

            data = json.encode({'data': tSearch.sublist(pageStart, pageEnd)});
          }
          else if (child == "week") {
            DateTime now = DateTime.now();
            int today = now.weekday;
            int week = int.parse(last);
            DateTime nextSunday = now.add(Duration(days: (7*week)+7-today));
            DateTime lastMonday = now.subtract(Duration(days: (-7*week)+today-1));
            DateTime weekStarts = DateTime(lastMonday.year, lastMonday.month, lastMonday.day, 0, 0, 0);
            DateTime weekEnds = DateTime(nextSunday.year, nextSunday.month, nextSunday.day, 23, 59, 50);

            final tSearch = _toknowDb.where((toknow) =>
                ((toknow.end != null) &&
                    (toknow.end!.isAfter(weekStarts)) &&
                    (toknow.end!.isBefore(weekEnds)) &&
                    (toknow.version != "DD")
                )
            ).toList();

            data = json.encode({'data': tSearch});
          }
          else if (child == "forgotten") {
            DateTime now = DateTime.now();
            int today = now.weekday;
            DateTime oldSunday = now.add(Duration(days: (-7-today)));
            DateTime weekEnds = DateTime(oldSunday.year, oldSunday.month, oldSunday.day, 23, 59, 50);

            final tSearch = _toknowDb.where((toknow) =>
                ((toknow.end != null) &&
                    (toknow.end!.isBefore(weekEnds)) &&
                    (toknow.version != "DD")
                )).toList();

            data = json.encode({'data': tSearch});
          }
          else if (child == "since") {
            DateTime since = DateTime.parse(last);
            final tSearch = _toknowDb.where((toknow) => (toknow.dayhour!.isAfter(since))).toList();

            data = json.encode({'data': tSearch});
          }
          else {
            String prefix = request.url.queryParameters['title'] ?? '';
            final regExp = RegExp(prefix, caseSensitive: false);
            final tSearch = _toknowDb.where((toknow) => toknow.title.contains(regExp)).toList();

            data = json.encode({'data': tSearch.sublist(0, min(tSearch.length, 10))});
          }
        }
        else if (parent == "toknow") {
          final id = int.tryParse(last.substring(last.indexOf('0')));
          if (id != null) {
            // necessite de faire un try catch...
            try {
              var toknow = _toknowDb.firstWhere((toknow) => toknow.id == last); // throws if no match
              data = json.encode({'data': toknow.toJson()});
            } catch (e) {
              data = json.encode({'data': null});
            }
          }
        }
        else if (parent == "tags") {
          data = json.encode({'data': _tagDb.toList()});
        }
        else if (parent == "tag") {
          // necessite de faire un try catch...
          try {
            var tag = _tagDb.firstWhere((tag) => tag.name == last);
            data = json.encode({'data': tag.toJson()});
          } catch (e) {
            data = json.encode({'data': null});
          }
        }
        break;
      case 'POST':
        if (json.decode(request.body)['id'] != null) {
          final newToknow = Toknow.fromJson(json.decode(request.body));
          _toknowDb.add(newToknow);
          updateTagDb(newToknow.tag);
          data = json.encode({'data': newToknow.toJson()});
        } 
        else {
          final id = _user + numToknowFormat.format(giveMaxToknowId(_user)+1);
          DateTime? dayhour = DateTime.now();
          final version = "00";
          final title = json.decode(request.body)['title'];
          String? description = json.decode(request.body)['description'];
          final done = false;
          final tag = json.decode(request.body)['tag'];
          final color = json.decode(request.body)['color'];
          DateTime? end;
          if (json.decode(request.body)['end'] != "") end = DateTime.tryParse(json.decode(request.body)['end']);
          final priority = 0;
          final quick = false;
          final crypto = false;
          final newToknow = Toknow(id,dayhour,version,title,description,done,tag,color,end,priority,quick,crypto);
          _toknowDb.insert(0,newToknow);
          updateTagDb(newToknow.tag);
          data = json.encode({'data': newToknow.toJson()});
          // special, in some cases, there is no message ton send immediatly
          String? nomessage = json.decode(request.body)['nomessage'];
          if (nomessage == null) {
            MessageService.send("post done");
          }
        }
        break;
      case 'PUT':
        if (parent == "key") {
          if (last == "key") {
            _key = '';
            data = json.encode({'data': false});
          }
          else {
            _key = last;
            data = json.encode({'data': true});
          }
        }
        else if (parent == "user") {
          // save the IV with the user
          _user = last;
          if (json.decode(request.body)['email'] != null) {
            _email = json.decode(request.body)['email'];
          }
          if (json.decode(request.body)['token'] != null) {
            _token = json.decode(request.body)['token'];
          }
          data = json.encode({'data': true});
        }
        else if (parent == "lang") {
          _lang = last;
          data = json.encode({'data': true});
        }
        else {
          final toknowChanges = Toknow.fromJson(json.decode(request.body));
          var targetToknow = _toknowDb.firstWhere((toknow) => toknow.id == toknowChanges.id);
          targetToknow.dayhour = DateTime.now();
          targetToknow.version = toknowChanges.version;
          targetToknow.title = toknowChanges.title.trim();
          targetToknow.description = toknowChanges.description;
          targetToknow.done = toknowChanges.done;
          if (toknowChanges.tag.isNotEmpty) {
            // tag must not have white space
            if (toknowChanges.tag.trim().indexOf(" ") == -1) {
              targetToknow.tag = toknowChanges.tag.trim();
            }
            else {
              targetToknow.tag = toknowChanges.tag.substring(0, toknowChanges.tag.indexOf(" "));
            }
          }
          else {
            targetToknow.tag = "notag";
          }
          targetToknow.color = toknowChanges.color;
          targetToknow.end = toknowChanges.end;
          targetToknow.priority = toknowChanges.priority;
          targetToknow.quick = toknowChanges.quick;
          targetToknow.crypto = toknowChanges.crypto;
          updateTagDb(targetToknow.tag);
          data = json.encode({'data': targetToknow.toJson()});
          MessageService.send("put done");
        }
        break;
      case 'DELETE':
        if (parent == "toknow") {
          final toknowDelete = Toknow.fromJson(json.decode(request.body));
          // print("debug... delete ${toknowDelete.id}");
          _toknowDb.removeWhere((toknow) => toknow.id == toknowDelete.id);
          data = json.encode({'data': true});
        }
        else if (parent == "tag") {
          final tagDelete = Tag.fromJson(json.decode(request.body));
          // print("debug... delete ${tagDelete.name}");
          _tagDb.removeWhere((tag) => tag.name == tagDelete.name);
          data = json.encode({'data': true});
        }
        else if (parent == "all") {
          resetDb();
          _user = '';
          _email = '';
          _key = '';
          _token = '';
          data = json.encode({'data': true});
        }
        break;
      default:
        throw 'Unimplemented HTTP method ${request.method}';
    }
    return Response(data, 200,
        headers: {'content-type': 'application/json'});
  }

  InMemoryDataService() : super(_handler) {
    resetDb();
  }
}
