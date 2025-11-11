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
  selector: 'forgotten-list',
  templateUrl: 'forgotten_list_component.html',
  styleUrls: ['forgotten_list_component.css'],
  directives: [coreDirectives, formDirectives],
  providers: [
    ClassProvider(AppConfig),
  ],
)

class ForgottenListComponent implements OnInit {
  List<Toknow> toknows = <Toknow>[];
  final InMemoryDataService _inMemoryDataService;
  final _headers = {'Content-Type': 'application/json'};
  final _mockUrlToknows = 'api/toknows/forgotten';
  final _mockUrlToknow = 'api/toknow';
  final Router _router;
  final AppConfig config;
  String title = '';
  String deleteStr = '';
  String editStr = '';
  String nothingStr = '';
  String sharedStr = '';
  String quickStr = '';
  String shareUser = '';
  int langId = 0;

  ForgottenListComponent(this._inMemoryDataService, this._router, this.config) {
    MessageService.doneController.stream.listen((event) {
      if (event.toString() == "local init done") {
        _getToknows();
      }
    });
  }

  @override
  void ngOnInit() async {
    langId = await Commons.getLang();
    title = config.theForgotten[langId];
    deleteStr = config.delete[langId];
    editStr = config.edit[langId];
    nothingStr = config.nothing[langId];
    sharedStr = config.shared[langId];
    quickStr = config.quick[langId];
    shareUser = config.shareUser;
    _getToknows();
  }

  String _toknowUrl(String id) => RoutePaths.toknow.toUrl(parameters: {idParam: '$id'});

  Future<NavigationResult> goToknowDetail(String id) => _router.navigate(_toknowUrl(id));

  dynamic _extractData(Response resp) => json.decode(resp.body)['data'];

  Future<void> _getToknows() async {
    try {
      final responseA = await _inMemoryDataService.get(
          Uri.parse(_mockUrlToknows));
      toknows = (_extractData(responseA) as List)
          .map((json) => Toknow.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
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

  void remove (Toknow? toknow) {
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



  Exception _handleError(dynamic e) {
    print('forgotten list error; cause: $e !'); // for demo purposes only
    return Exception('forgotten list error; cause: $e !');
  }
}