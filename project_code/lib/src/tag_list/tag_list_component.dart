import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import '../../in_memory_data_service.dart';
import 'tag.dart';
//import '../todo_list/todo_list_component.dart';

@Component(
  selector: 'tag-list',
  styleUrls: const ['tag_list_component.css'],
  templateUrl: 'tag_list_component.html',
  directives: const [
    CORE_DIRECTIVES,
    //TodoListComponent,
    ROUTER_DIRECTIVES,
  ],
)

class TagListComponent implements OnInit {
  List<Tag> tagItems=[];
  final Router _router;

  TagListComponent(this._router);

  void ngOnInit() {
    tagItems = InMemoryDataService.giveListOfTags();
  }


  void goTodoList(Tag t) => _router.navigate([
    'List',
    {'tag': t.tagName}
  ]);



  void goAccueil() => _router.navigate([
    'Dashboard'
  ]);



}