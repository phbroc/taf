import 'package:ngdart/angular.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:ngrouter/ngrouter.dart';
import 'package:ngrouter/angular_router.dart';
import 'toknow.dart';
import 'dart:async';
import '../../app_config.dart';
import '../commons.dart';
import '../toknow_search_service.dart';
import '../route_paths.dart';

@Component(
  selector: 'toknow-search',
  templateUrl: 'toknow_search_component.html',
  styleUrls: ['toknow_search_component.css'],
  directives: [
    coreDirectives,
    routerDirectives
  ],
  providers: [
    ClassProvider(AppConfig),
    ClassProvider(ToknowSearchService),
  ],
  pipes: [commonPipes],
)

class ToknowSearchComponent implements OnInit {
  final ToknowSearchService _toknowSearchService;
  final AppConfig config;
  final Router _router;
  final _headers = {'Content-Type': 'application/json'};
  final _mockUrlAllToknows = 'api/toknows';
  String searchStr = '';
  String titleStr = '';
  String editStr = '';
  String sharedStr = '';
  String quickStr = '';
  String shareUser = '';
  int langId = 0;
  late Stream<List<Toknow>> toknows;
  StreamController<String> _searchTerms = StreamController<String>.broadcast();

  ToknowSearchComponent(this.config, this._toknowSearchService, this._router) {
    toknows = Stream<List<Toknow>>.fromIterable([<Toknow>[]]);
  }

  String _toknowUrl(String id) => RoutePaths.toknow.toUrl(parameters: {idParam: '$id'});

  Future<NavigationResult> goToknowDetail(String id) => _router.navigate(_toknowUrl(id));

  Future<void> _getToknows() async {
    toknows = _searchTerms.stream
        .debounce(Duration(milliseconds: 300))
        .distinct()
        .switchMap((term) => term.isEmpty
        ? Stream<List<Toknow>>.fromIterable([<Toknow>[]])
        : _toknowSearchService.search(term).asStream())
        .handleError((e) {
      print("search error $e"); // for demo purposes only
    });
  }

  void search(String term) => _searchTerms.add(term);

  @override
  void ngOnInit() async {
    langId = await Commons.getLang();
    searchStr = config.search[langId];
    titleStr = config.title[langId];
    editStr = config.edit[langId];
    sharedStr = config.shared[langId];
    quickStr = config.quick[langId];
    shareUser = config.shareUser;
    _getToknows();
  }

  String toknowUrl(String id) => RoutePaths.toknow.toUrl(parameters: {idParam: id});

}