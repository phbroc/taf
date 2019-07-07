import 'package:angular_router/angular_router.dart';

import 'route_paths.dart';
import 'dashboard_component.template.dart' as dashboard_template;
import 'login_component.template.dart' as login_template;
import 'todo_list/todo_list_component.template.dart' as todo_list_template;
import 'todo_list/todo_detail_component.template.dart' as todo_detail_template;
import 'todo_list/todo_add_component.template.dart' as todo_add_template;
import 'tag_list/tag_list_component.template.dart' as tag_list_template;


export 'route_paths.dart';

class Routes {
  static final accueil = RouteDefinition(
    routePath: RoutePaths.accueil,
    component: dashboard_template.DashboardComponentNgFactory,
  );

  static final login = RouteDefinition(
    routePath: RoutePaths.login,
    component: login_template.LoginComponentNgFactory,
  );

  static final list = RouteDefinition(
    routePath: RoutePaths.list,
    component: todo_list_template.TodoListComponentNgFactory,
  );

  static final listtag = RouteDefinition(
    routePath: RoutePaths.listtag,
    component: todo_list_template.TodoListComponentNgFactory,
  );

  static final detail = RouteDefinition(
    routePath: RoutePaths.detail,
    component: todo_detail_template.TodoDetailComponentNgFactory,
  );

  static final tag = RouteDefinition(
    routePath: RoutePaths.tag,
    component: tag_list_template.TagListComponentNgFactory,
  );

  static final add = RouteDefinition(
    routePath: RoutePaths.add,
    component: todo_add_template.TodoAddComponentNgFactory,
  );

  static final all = <RouteDefinition>[
    accueil,
    login,
    list,
    listtag,
    detail,
    tag,
    add,
    RouteDefinition.redirect(
      path: '',
      redirectTo: RoutePaths.accueil.toUrl(),
    ),
  ];
}