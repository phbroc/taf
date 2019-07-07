// Copyright (c) 2017, philippe. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:taf/app_component.template.dart' as ng;
import 'package:http/browser_client.dart';
import 'main.template.dart' as self;
// test de pwa pour gérer le offline
import 'package:pwa/client.dart' as pwa;

@GenerateInjector([
  routerProvidersHash, // You can use routerProviders in production
  ClassProvider(BrowserClient),
])

final InjectorFactory injector = self.injector$Injector;

void main() {
  runApp(ng.AppComponentNgFactory, createInjector: injector);
  // register PWA ServiceWorker for offline caching.
  pwa.Client();
}
