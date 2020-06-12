import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/material_popup/material_popup.dart';
import 'package:angular_components/laminate/overlay/zindexer.dart';
import 'package:angular_components/laminate/popup/module.dart';
import 'package:angular_components/laminate/popup/popup.dart';

import 'package:intl/intl.dart';
import 'package:angular_router/angular_router.dart';
import '../../in_memory_data_service.dart';
import '../todo_list/todo.dart';
import '../route_paths.dart';
import '../../event_bus.dart';


@Component(
  selector: 'week-list',
  styleUrls: ['week_list_component.css'],
  templateUrl: 'week_list_component.html',
  directives: [
    coreDirectives,
    MaterialCheckboxComponent,
    MaterialPopupComponent,
    PopupSourceDirective,
    MaterialIconComponent,
    MaterialFabComponent,
  ],
  providers: [
    materialProviders,
    popupBindings, ClassProvider(ZIndexer)
  ],
)

class WeekListComponent implements OnInit {
  List<Todo> todoItems=[];
  final nformat = NumberFormat("000000");
  final dformat = DateFormat('yyyy-MM-dd HH:mm:ss');
  // Keep track of each popup's visibility separately.
  final visible = List.filled(11, false);
  List<RelativePosition> position = [RelativePosition.AdjacentTop, RelativePosition.AdjacentTopLeft, RelativePosition.AdjacentTopRight, RelativePosition.AdjacentBottom, RelativePosition.AdjacentBottomRight, RelativePosition.AdjacentBottomLeft];

  final Router _router;
  final EventBus eventBus;

  String _totoItemUrl(String id) => RoutePaths.detail.toUrl(parameters: {idParam: '$id'});

  WeekListComponent(this._router, this.eventBus);

  void ngOnInit() {
    todoItems = InMemoryDataService.giveWeekTodo();

  }

  void popupDetail(Todo todoItem) {

  }

  void remove(Todo todoItem) {
    todoItem.version = "DD";
    var now = DateTime.now();
    todoItem.dayhour = dformat.format(now);
    // notification todochanged save local
    eventBus.onEventTodoChanged(todoItem.id);
  }

  void doneOnOff(Todo todoItem, bool checked) {
    print("doneOnOff... " + todoItem.id + " -> " + checked.toString());
    var now = DateTime.now();
    todoItem.dayhour = dformat.format(now);
    todoItem.done = checked;
    // notification todochanged save local
    eventBus.onEventTodoChanged(todoItem.id);
  }

  Future<NavigationResult> gotoDetail(Todo todoItem) => _router.navigate(_totoItemUrl(todoItem.id));

  String giveWeekDay(DateTime d) {
    String retStr;
    switch(d.weekday) {
      case 1: retStr = "monday"; break;
      case 2: retStr = "tuesday"; break;
      case 3: retStr = "wednesday"; break;
      case 4: retStr = "thursday"; break;
      case 5: retStr = "friday"; break;
      case 6: retStr = "saturday"; break;
      case 7: retStr = "sunday"; break;
      default: retStr = "error"; break;
    }
    return retStr;
  }

}