import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:intl/intl.dart';
import 'package:angular_router/angular_router.dart';
import '../../in_memory_data_service.dart';
import '../todo_list/todo.dart';


@Component(
  selector: 'week-list',
  styleUrls: const ['week_list_component.css'],
  templateUrl: 'week_list_component.html',
  directives: const [
    CORE_DIRECTIVES,
    materialDirectives,

  ],
)

class WeekListComponent implements OnInit {
  List<Todo> todoItems=[];
  final nformat = new NumberFormat("000000");
  final dformat = new DateFormat('yyyy-MM-dd HH:mm:ss');
  // Keep track of each popup's visibility separately.
  final visible = new List.filled(11, false);
  List<RelativePosition> position = [RelativePosition.AdjacentTop, RelativePosition.AdjacentTopLeft, RelativePosition.AdjacentTopRight, RelativePosition.AdjacentBottom, RelativePosition.AdjacentBottomRight, RelativePosition.AdjacentBottomLeft];

  final Router _router;

  WeekListComponent(this._router);

  void ngOnInit() {
    todoItems = InMemoryDataService.giveWeekTodo();

  }

  void popupDetail(Todo todoItem) {

  }

  void remove(Todo todoItem) {
    todoItem.version = "DD";
    var now = new DateTime.now();
    todoItem.dayhour = dformat.format(now);
  }

  void doneOnOff(Todo todoItem, bool checked) {
    print("doneOnOff... " + todoItem.id + " -> " + checked.toString());
    var now = new DateTime.now();
    todoItem.dayhour = dformat.format(now);
    todoItem.done = checked;
  }

  void gotoDetail(Todo todoItem) => _router.navigate([
    'Detail',
    {'id': todoItem.id}
  ]);

  String giveWeekDay(DateTime d) {
    String retStr;
    switch(d.weekday) {
      case 1: retStr = "lundi"; break;
      case 2: retStr = "mardi"; break;
      case 3: retStr = "mercredi"; break;
      case 4: retStr = "jeudi"; break;
      case 5: retStr = "vendredi"; break;
      case 6: retStr = "samedi"; break;
      case 7: retStr = "dimanche"; break;
      default: retStr = "error"; break;
    }
    return retStr;
  }

}