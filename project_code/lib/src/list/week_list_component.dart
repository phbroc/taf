import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
import 'package:http/http.dart';
import 'package:ngrouter/ngrouter.dart';
import '../toknow/toknow.dart';
import '../../in_memory_data_service.dart';
import '../../message_service.dart';
import 'dart:async';
import 'dart:convert';
import '../route_paths.dart';
import "../tag/tag.dart";
import '../../app_config.dart';
import '../commons.dart';

@Component(
  selector: 'week-list',
  templateUrl: 'week_list_component.html',
  styleUrls: ['week_list_component.css'],
  directives: [coreDirectives, formDirectives],
  providers: [
    ClassProvider(AppConfig),
  ],
)

class WeekListComponent implements OnInit {
  List<Toknow> toknows = <Toknow>[];
  final InMemoryDataService _inMemoryDataService;
  final _headers = {'Content-Type': 'application/json'};
  final _mockUrlToknows = 'api/toknows/week';
  final _mockUrlToknow = 'api/toknow';
  final Router _router;
  final AppConfig config;
  bool _initialized = false;
  int week = 0;
  String title = '';
  String nextStr = '';
  String previousStr = '';
  String deleteStr = '';
  String nothingStr = '';
  String readMoreStr = '';
  String editStr = '';
  String closeStr = '';
  String sharedStr = '';
  String shareUser = '';
  int langId = 0;
  bool more = false;
  String? moreDescription;
  late String moreId;
  String? moreDay;
  int moreColor = 0;
  String moreTag = 'notag';

  WeekListComponent (this._inMemoryDataService, this._router, this.config) {
    MessageService.doneController.stream.listen((event) {
      if ((event.toString() == "post done") ||
          (event.toString() == "put done") ||
          (event.toString() == "local init done")) {
        _getToknows();
      }
    });
  }

  String _toknowUrl(String id) => RoutePaths.toknow.toUrl(parameters: {idParam: '$id'});

  Future<NavigationResult> goToknowDetail(String id) => _router.navigate(_toknowUrl(id));

  dynamic _extractData(Response resp) => json.decode(resp.body)['data'];

  Future<void> _getToknows() async {
    try {
      final response = await _inMemoryDataService.get(Uri.parse("$_mockUrlToknows/$week"));
      toknows = (_extractData(response) as List)
          .map((json) => Toknow.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // use OnActivate when component have to get params from the router
  @override
  void ngOnInit() async {
    langId = await Commons.getLang();
    title = config.weekListTitleThis[langId];
    nextStr = config.weekListNext[langId];
    previousStr = config.weekListPrevious[langId];
    deleteStr = config.delete[langId];
    nothingStr = config.nothing[langId];
    readMoreStr = config.readMore[langId];
    editStr = config.edit[langId];
    closeStr = config.close[langId];
    sharedStr = config.shared[langId];
    shareUser = config.shareUser[langId];
    _getToknows();
  }

  void doneOnOff(Toknow? toknow, bool? done) {
    if (done != null) {
      toknow?.done = done;
      final tokPut = toknow?.toJson();
      final url = '$_mockUrlToknow/${toknow?.id}';
      toknow?.dayhour = DateTime.now();
      try {
        final response = _inMemoryDataService.put(Uri.parse(url),
            headers: _headers,
            body: jsonEncode(tokPut));
      } catch (e) {
        throw _handleError(e);
      }
    }
  }

  void updateTitle() {
    switch (week) {
      case -1:
        title = config.weekListTitleLast[langId];
        break;
      case 0:
        title = config.weekListTitleThis[langId];
        break;
      case 1:
        title = config.weekListTitleNext[langId];
        break;
      default:
        title = "";
        break;
    }
  }

  void nextToknows() {
    week++;
    _getToknows();
    updateTitle();
  }

  void previousToknows() {
    week--;
    _getToknows();
    updateTitle();
  }

  void remove(Toknow? toknow) {
    final url = '$_mockUrlToknow/${toknow?.id}';
    toknow?.dayhour = DateTime.now();
    toknow?.version = "DD";
    final tokDel = toknow?.toJson();
    try {
      final response = _inMemoryDataService.put(Uri.parse(url),
          headers: _headers,
          body: jsonEncode(tokDel));
    } catch (e) {
      throw _handleError(e);
    }
  }

  void read(String? id, String? description, DateTime? end, String tag) {
    more = true;
    moreDescription = description;
    moreId = id!;
    int theDay = end!.weekday;
    moreDay = config.days[(7*langId)+theDay-1];
    moreTag = tag;
    moreColor = Commons.stringToModuloIndex(tag, 80);
  }

  void close() {
    more = false;
    moreDescription = null;
  }

  bool isInThePast(DateTime? d) {
    DateTime today = DateTime.now();
    if (d != null) {
      if (d.isBefore(today)) { return true; }
      else { return false; }
    }
    else { return false; }
  }

  Exception _handleError(dynamic e) {
    print('week list error; cause: $e !'); // for demo purposes only
    return Exception('week list error; cause: $e !');
  }
}