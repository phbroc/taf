import 'package:ngdart/angular.dart';
import 'package:http/http.dart';
import 'toknow.dart';
import 'dart:async';
import 'dart:html';
import 'dart:convert';
import '../../in_memory_data_service.dart';
import '../tag/tag.dart';
import '../../app_config.dart';
import '../commons.dart';

@Component(
  selector: 'toknow-add',
  templateUrl: 'toknow_add_component.html',
  styleUrls: ['toknow_add_component.css'],
  directives: [coreDirectives],
  providers: [
    ClassProvider(AppConfig),
  ]
)

class ToknowAddComponent implements OnInit {
  final InMemoryDataService _inMemoryDataService;
  final AppConfig config;
  final _headers = {'Content-Type': 'application/json'};
  final _mockUrl = 'api/toknow';
  final _mockUrlAllToknows = 'api/toknows';
  late Toknow _nextToknow;
  String addStr = '';
  String newToknowStr = '';
  String titleRequiredStr = '';
  int langId = 0;
  bool errorFormAdd = false;
  String formAddMessage = '';

  @Input()
  Tag? tag;

  ToknowAddComponent(this._inMemoryDataService, this.config);

  @override
  void ngOnInit() async {
    langId = await Commons.getLang();
    addStr = config.add[langId];
    newToknowStr = config.newToknow[langId];
    titleRequiredStr = config.titleRequired[langId];
  }

  dynamic _extractData(Response resp) => json.decode(resp.body)['data'];

  List<String> decodeNewTodo(String s) {
    var title = "";
    String description;
    String tag;
    String end;
    List<String> retList = <String>[];

    // find #tag ?
    RegExp expTag = RegExp(r"(#[a-zA-Z0-9éèêàôïç]+)");
    Match? matches = expTag.firstMatch(s);
    if (matches != null) {
      tag = "${matches.group(0)}";
      tag = tag.substring(1,tag.length);
      s = s.replaceFirst(expTag, '');
    }
    else {
      tag = "";
    }
    
    // find end ?
    expTag = RegExp(r"(\+[0-9])");
    matches = expTag.firstMatch(s);
    if (matches != null) {
      String days = "${matches.group(0)}";
      int nbdays = int.tryParse(days.substring(1,2))!;
      DateTime today = DateTime.now();
      DateTime dayhour = DateTime(today.year, today.month, today.day, 23, 45, 0);
      if (nbdays > 0) {
        dayhour = dayhour.add(Duration(days: nbdays));
      }
      end = dayhour.toIso8601String();
      s = s.replaceFirst(expTag, '');
    }
    else {
      end = "";
    }
    

    // find description ?
    if (s.contains(";")) {
      title = s.substring(0, s.indexOf(";")).trim();
      description = s.substring(s.indexOf(";")+1).trim();
    }
    else {
      title = s.trim();
      description = "";
    }

    retList.add(title);
    retList.add(description);
    retList.add(tag);
    retList.add(end);
    return retList;
  }

  Future<void> add(InputElement input) async {
    final next = "${input.value?.trim()}";
    List<String> decodeNext = decodeNewTodo(next);
    String title = decodeNext[0];
    String description = decodeNext[1];
    String tagName = decodeNext[2];
    if (tagName.isEmpty) {
      if (tag != null) {tagName = "${tag?.name}";}
      else {tagName = "notag";}
    }
    int color = Commons.stringToModuloIndex(tagName, 80);
    String endStr = decodeNext[3];

    if (title != "") {
      try {
        final response = await _inMemoryDataService.post(
            Uri.parse(_mockUrl),
            headers: _headers,
            body: json.encode({'id': null, 'title': title, 'description': description, 'tag': tagName, 'color': color, 'end': endStr})
        );
        // next toknow in the response ...
        // _nextToknow = Toknow.fromJson(_extractData(response));
      } catch (e) {
        throw _handleError(e);
      }
      input.value = "";
      errorFormAdd = false;
      formAddMessage = "";
    }
    else {
      errorFormAdd = true;
      formAddMessage = titleRequiredStr;
    }
  }

  Exception _handleError(dynamic e) {
    print('Add component mock error; cause: $e !'); // for demo purposes only
    return Exception('Add component error; cause: $e !');
  }
}

