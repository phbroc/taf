import 'package:angular_components/angular_components.dart';
import 'package:angular2/angular2.dart';
import 'package:angular2/platform/common.dart';
import 'package:angular2/router.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'todo.dart';
import 'package:taf/in_memory_data_service.dart';
import '../utils/converter.dart';

@Component(
  selector: 'todo-detail',
  styleUrls: const ['todo_detail_component.css'],
  templateUrl: 'todo_detail_component.html',
  directives: const [
    CORE_DIRECTIVES,
    FORM_DIRECTIVES,
    materialDirectives,
  ],
)

class TodoDetailComponent implements OnInit {
  @Input()
  Todo todoItem;

  final Location _location;
  final RouteParams _routeParams;

  final nformat = new NumberFormat("000000");
  final dformat = new DateFormat('yyyy-MM-dd HH:mm:ss');

  TodoDetailComponent(this._location, this._routeParams);

  Future<Null> ngOnInit() async {
    var id = _routeParams.get('id');
    if (id != null) todoItem = await InMemoryDataService.giveById(id);
    print("detail..." + todoItem.title);
  }

  void goBack() => _location.back();

  void onChanged() {
    //print("onChanged...");
    var now = new DateTime.now();
    todoItem.dayhour = dformat.format(now);

    if (todoItem.tag != "") todoItem.color = Converter.stringToModuloIndex(todoItem.tag, 80) +1;
    else todoItem.color = 0;
  }
}



