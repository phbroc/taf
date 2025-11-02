import 'package:ngdart/angular.dart';
import 'package:ngrouter/ngrouter.dart';
import 'package:taf2/app_component.template.dart' as ng;
import 'package:taf2/in_memory_data_service.dart';
import 'main.template.dart' as self;

@GenerateInjector([
  ClassProvider(InMemoryDataService),
  routerProvidersHash,  // You can use routerProviders in prod
])

final InjectorFactory injector = self.injector$Injector;

void main() {
  runApp(ng.AppComponentNgFactory, createInjector: injector);
}
