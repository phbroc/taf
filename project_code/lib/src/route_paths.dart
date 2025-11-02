import 'package:ngrouter/ngrouter.dart';

const idParam = 'id';
const nameParam = 'notag';
const pageParam = '1';

class RoutePaths {
  static final dashboard = RoutePath(path: 'dashboard');
  static final toknow = RoutePath(path: 'toknow/:$idParam');
  static final taglist = RoutePath(path: 'taglist/:$nameParam/:$pageParam');
  static final login = RoutePath(path: 'login');
}

String? getId(Map<String, String> parameters) {
  final id = parameters[idParam];
  return id;
}

String? getName(Map<String, String> parameters) {
  final name = parameters[nameParam];
  return name;
}

String? getPage(Map<String, String> parameters) {
  final page = parameters[pageParam];
  return page;
}