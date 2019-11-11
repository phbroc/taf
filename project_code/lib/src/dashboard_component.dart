import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'tag_list/tag_list_component.dart';
import 'ordered_list/week_list_component.dart';
import 'todo_list/todo_add_component.dart';

@Component(
  selector: 'dashboard',
  styleUrls: ['dashboard_component.css'],
  templateUrl: 'dashboard_component.html',
  directives: [
    coreDirectives,
    routerDirectives,
    TagListComponent,
    WeekListComponent,
    TodoAddComponent,
  ],
)

class DashboardComponent {



}
