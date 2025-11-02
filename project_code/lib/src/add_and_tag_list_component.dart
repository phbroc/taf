import 'package:ngdart/angular.dart';
import 'package:ngrouter/ngrouter.dart';
import '../app_config.dart';
import 'toknow/toknow_add_component.dart';
import 'list/tag_list_component.dart';
import "tag/tag.dart";
import "../in_memory_data_service.dart";
import '../../message_service.dart';
import "route_paths.dart";
import 'dart:convert';
import 'package:http/http.dart';
import 'commons.dart';

@Component(
  selector: 'add-and-tag-list',
  templateUrl: 'add_and_tag_list_component.html',
  styleUrls: ['add_and_tag_list_component.css'],
  providers: [
    ClassProvider(AppConfig),
  ],
  directives: [
    ToknowAddComponent,
    TagListComponent,
    coreDirectives,
    routerDirectives,
  ],
)

class AddAndTagListComponent  implements OnInit, OnActivate {
  final InMemoryDataService _inMemoryDataService;
  final AppConfig config;
  final Router _router;
  final _headers = {'Content-Type': 'application/json'};
  final _mockUrl = 'api/tag';
  final _mockUrlPages = 'api/pages';
  String title = '';
  String prevPageStr = '';
  String nextPageStr = '';
  int langId = 0;
  Tag? tagSelected;
  String? page;
  String maxPage = "1";
  String? tagName;

  AddAndTagListComponent(this.config, this._inMemoryDataService, this._router) {
    MessageService.doneController.stream.listen((event) {
      if ((event.toString() == "post done") ||
          (event.toString() == "put done") ||
          (event.toString() == "local init done")) {
        _getMaxPage();
      }
    });
  }

  dynamic _extractData(Response resp) => json.decode(resp.body)['data'];

  Future<void> _getTag() async {
    try {
      final response = await _inMemoryDataService.get(Uri.parse("$_mockUrl/$tagName"));
      if (_extractData(response) != null) {
        tagSelected = Tag.fromJson(_extractData(response));
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> _getMaxPage() async {
    if (tagName != null) {
      final responseP = await _inMemoryDataService.get(Uri.parse("$_mockUrlPages/$tagName"));
      maxPage = _extractData(responseP).toString();
    }
  }

  @override
  void ngOnInit() async {
    langId = await Commons.getLang();
    title = config.tagListTitle[langId];
    prevPageStr = config.prevPage[langId];
    nextPageStr = config.nextPage[langId];
  }

  @override
  void onActivate(_, RouterState current) async {
    page = getPage(current.parameters);
    tagName = getName(current.parameters);
    if (tagName != null) {
      await _getTag();
      await _getMaxPage();
    }
  }

  String _tagListUrl(String name, String p) => RoutePaths.taglist.toUrl(parameters: {nameParam: name, pageParam: p});

  Future<NavigationResult> nextPage() {
    page = (1+int.parse(page!)).toString();
    return _router.navigate(_tagListUrl(tagSelected!.name, page!));
  }

  Future<NavigationResult> prevPage() {
    page = (int.parse(page!)-1).toString();
    return _router.navigate(_tagListUrl(tagSelected!.name, page!));
  }

  Exception _handleError(dynamic e) {
    print('Add and Tag List error; cause: $e !'); // for demo purposes only
    return Exception('Add and Tag List component error; cause: $e !');
  }
}