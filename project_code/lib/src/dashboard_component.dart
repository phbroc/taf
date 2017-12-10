import 'package:angular/angular.dart';
import 'tag_list/tag_list_component.dart';

@Component(
  selector: 'dashboard',
  styleUrls: const ['dashboard_component.css'],
  templateUrl: 'dashboard_component.html',
  directives: const [
    CORE_DIRECTIVES,
    TagListComponent,
  ],
)

class DashboardComponent {



}
