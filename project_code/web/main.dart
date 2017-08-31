// Copyright (c) 2017, philippe. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:angular2/angular2.dart';
import 'package:angular2/platform/browser.dart';
// j'ajouterai cet import si j'utilise un vrai serveur
import 'package:http/browser_client.dart';

import 'package:taf/app_component.dart';
//import 'package:taf/in_memory_data_service.dart';
import 'package:http/http.dart';

//import 'package:taf/in_memory_data.dart';

void main() {
  bootstrap(AppComponent,
    // [provide(Client, useClass: InMemoryDataService)]
    // Using a real back end?
    // Import browser_client.dart and change the above to:
    [provide(Client, useFactory: () => new BrowserClient(), deps: [])]
    // []
  );
}
