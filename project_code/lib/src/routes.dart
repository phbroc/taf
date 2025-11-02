import 'package:ngrouter/ngrouter.dart';
import 'route_paths.dart';
import 'add_and_tag_list_component.template.dart' as add_and_tag_list_template;
import 'toknow/toknow_detail_component.template.dart' as toknow_detail_template;
import 'dashboard_component.template.dart' as dashboard_template;
import 'login_component.template.dart' as login_template;

export 'route_paths.dart';

class Routes {
  static final taglist = RouteDefinition(
    routePath: RoutePaths.taglist,
    component: add_and_tag_list_template.AddAndTagListComponentNgFactory,
  );
  static final toknow = RouteDefinition(
    routePath: RoutePaths.toknow,
    component: toknow_detail_template.ToknowDetailComponentNgFactory,
  );

  static final dashboard = RouteDefinition(
    routePath: RoutePaths.dashboard,
    component: dashboard_template.DashboardComponentNgFactory,
  );

  static final login = RouteDefinition(
    routePath: RoutePaths.login,
    component: login_template.LoginComponentNgFactory,
  );

  static final all = <RouteDefinition>[
    dashboard,
    taglist,
    toknow,
    login,
    RouteDefinition.redirect(
      path: '',
      redirectTo: RoutePaths.dashboard.toUrl(),
    ),
  ];
}
