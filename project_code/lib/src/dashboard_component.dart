import 'package:ngdart/angular.dart';
import 'toknow/toknow_add_component.dart';
import 'tag/tags_component.dart';
import 'list/week_list_component.dart';
import 'list/forgotten_list_component.dart';
import 'toknow/toknow_search_component.dart';
import '../app_config.dart';
import 'commons.dart';

@Component(
    selector: 'dashboard',
    templateUrl: 'dashboard_component.html',
    styleUrls: ['dashboard_component.css'],
    directives: [
      ToknowAddComponent,
      TagsComponent,
      WeekListComponent,
      ToknowSearchComponent,
      ForgottenListComponent,
    ],
    providers: [
      ClassProvider(AppConfig),
    ]
)

class DashboardComponent implements OnInit {
  final AppConfig config;
  String title = '';
  int langId = 0;

  DashboardComponent(this.config);

  @override
  void ngOnInit() async {
    langId = await Commons.getLang();
    title = config.dashboardTitle[langId];
  }
}