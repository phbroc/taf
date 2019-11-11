import 'package:angular_router/angular_router.dart';

const tagParam = 'tag';
const idParam = 'id';

class RoutePaths {
  static final accueil = RoutePath(path: 'accueil');
  static final params = RoutePath(path: 'params');
  static final list = RoutePath(path: 'list');
  static final listtag = RoutePath(path: '${list.path}/:$tagParam');
  static final detail = RoutePath(path: 'detail/:$idParam');
  static final tag = RoutePath(path: 'tag');
  static final add = RoutePath(path: 'add');
}

String getId(Map<String, String> parameters) {
  final id = parameters[idParam];
  return id;
}

String getTag(Map<String, String> parameters) {
  final tag = parameters[tagParam];
  return tag;
}