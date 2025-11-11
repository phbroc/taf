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
  selector: 'tag-list',
  templateUrl: 'tag_list_component.html',
  styleUrls: ['tag_list_component.css'],
  directives: [coreDirectives, formDirectives],
  providers: [
    ClassProvider(AppConfig),
  ],
)

class TagListComponent implements OnInit, DoCheck {
  List<Toknow> toknows = <Toknow>[];
  final InMemoryDataService _inMemoryDataService;
  final _headers = {'Content-Type': 'application/json'};
  final _mockUrlToknows = 'api/toknows/tag';
  final _mockUrlToknow = 'api/toknow';
  final _mockUrlTag = 'api/tag';
  final Router _router;
  final AppConfig config;
  bool _initialized = false;
  bool noMoreToknows = false;
  String deleteStr = '';
  String editStr = '';
  String nothingStr = '';
  String sharedStr = '';
  String shareUser = '';
  String quickStr = '';
  int langId = 0;

  @Input()
  Tag? tag;

  @Input()
  String? page;

  TagListComponent(this._inMemoryDataService, this._router, this.config) {
    MessageService.doneController.stream.listen((event) {
      if ((event.toString() == "post done") ||
          (event.toString() == "put done") ||
          (event.toString() == "local init done")) {
        if ((tag != null) && (page != null)) {
          _getToknows();
        }
      }
    });
  }

  String _toknowUrl(String id) => RoutePaths.toknow.toUrl(parameters: {idParam: '$id'});

  Future<NavigationResult> goToknowDetail(String id) => _router.navigate(_toknowUrl(id));

  dynamic _extractData(Response resp) => json.decode(resp.body)['data'];

  Future<void> _getToknows() async {
    try {
      if (page != null) {
        final responseP = await _inMemoryDataService.get(Uri.parse("$_mockUrlToknows/${tag!.name}/$page"));
        toknows = (_extractData(responseP) as List)
            .map((json) => Toknow.fromJson(json))
            .toList();
        if ((toknows.isEmpty) && (page == 1)) {
          noMoreToknows = true;
          removeTag();
        }
      }
      else {
        final responseA = await _inMemoryDataService.get(Uri.parse("$_mockUrlToknows/${tag!.name}"));
        toknows = (_extractData(responseA) as List)
            .map((json) => Toknow.fromJson(json))
            .toList();
        if (toknows.isEmpty) {
          noMoreToknows = true;
          removeTag();
        }
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // use OnActivate when component have to get params from the router
  @override
  void ngOnInit() async {
    langId = await Commons.getLang();
    deleteStr = config.delete[langId];
    editStr = config.edit[langId];
    nothingStr = config.nothing[langId];
    sharedStr = config.shared[langId];
    quickStr = config.quick[langId];
    shareUser = config.shareUser;
    // problem of life cycle, when OnInit the biding with the parent component is not ready
    // print("OnInit tagList ... ${tag?.name}");
  }

  // beware this method is often called, to prevent from looping there is the _initialized flag !
  @override
  void ngDoCheck() {
    if (!_initialized) {
      if ((tag != null) && (page != null)) {
        _initialized = true;
        _getToknows();
      }
    }
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

  void removeToknow(Toknow? toknow) {
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

  void removeTag() {
    final url = '$_mockUrlTag/${tag!.name}';
    final tagDel = tag!.toJson();
    try {
      final response = _inMemoryDataService.delete(Uri.parse(url),
          headers: _headers,
          body: jsonEncode(tagDel));
    } catch (e) {
      throw _handleError(e);
    }
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
    print('tag list error; cause: $e !'); // for demo purposes only
    return Exception('tag list error; cause: $e !');
  }
}