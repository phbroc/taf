import 'package:ngdart/angular.dart';
import 'package:ngrouter/angular_router.dart';
import 'package:http/http.dart';
import 'dart:convert';
import '../../in_memory_data_service.dart';
import '../../message_service.dart';
import '../../app_config.dart';
import '../route_paths.dart';
import '../commons.dart';
import 'tag.dart';

@Component(
  selector: 'tags',
  templateUrl: 'tags_component.html',
  styleUrls: ['tags_component.css'],
  directives: [
    coreDirectives,
    routerDirectives
  ],
  providers: [
    ClassProvider(AppConfig),
  ],
)

class TagsComponent implements OnInit  {
  List<Tag> tags = <Tag>[];
  final InMemoryDataService _inMemoryDataService;
  final _headers = {'Content-Type': 'application/json'};
  final _mockUrl = 'api/tags';
  final AppConfig config;
  String tagsStr = '';
  int langId = 0;

  TagsComponent(this._inMemoryDataService, this.config) {
    MessageService.doneController.stream.listen((event) {
      if ((event.toString() == "post done") || (event.toString() == "local init done")) {
        _getTags();
      }
    });
  }

  dynamic _extractData(Response resp) => json.decode(resp.body)['data'];

  Future<void> _getTags() async {
    try {
      final response = await _inMemoryDataService.get(Uri.parse(_mockUrl));
      tags = (_extractData(response) as List)
          .map((json) => Tag.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  void ngOnInit() async {
    langId = await Commons.getLang();
    tagsStr = config.tags[langId];
    _getTags();
  }

  String tagListUrl(String name) => RoutePaths.taglist.toUrl(parameters: {nameParam: name, pageParam: "1"});

  Exception _handleError(dynamic e) {
    print('Tags component error; cause: $e !'); // for demo purposes only
    return Exception('In memory error; cause: $e !');
  }
}