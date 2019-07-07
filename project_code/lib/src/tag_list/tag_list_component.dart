import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import '../route_paths.dart';
import '../../in_memory_data_service.dart';
import 'tag.dart';


@Component(
  selector: 'tag-list',
  styleUrls: ['tag_list_component.css'],
  templateUrl: 'tag_list_component.html',
  directives: [
    coreDirectives,
    routerDirectives,
  ],
)

class TagListComponent implements OnInit {
  List<Tag> tagItems=[];
  final Router _router;

  String listtagUrl(String tag) => RoutePaths.listtag.toUrl(parameters: {tagParam: '$tag'});

  TagListComponent(this._router);

  void ngOnInit() {
    tagItems = InMemoryDataService.giveListOfTags();
  }


  //Future<NavigationResult> goTodoList(Tag t) => _router.navigate(listtagUrl(t.tagName));

  //Future<NavigationResult> goAccueil() => _router.navigate(RoutePaths.accueil.toUrl());



}