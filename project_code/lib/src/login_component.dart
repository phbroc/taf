import 'package:angular_components/angular_components.dart';
import 'package:angular/angular.dart';

//import 'package:angular_forms/angular_forms.dart'; serait utile si j'ajoute formDirectives dans les directives

import 'package:taf/local_data_service.dart';
import 'package:taf/server_data_service.dart';
import 'dart:async';
import '../event_bus.dart';
import 'dart:html';

@Component(
  selector: 'login',
  styleUrls: ['login_component.css'],
  templateUrl: 'login_component.html',
  directives: [coreDirectives,
                MaterialInputComponent,
                MaterialFabComponent,
                MaterialIconComponent,
                materialInputDirectives,
              ],

)

class LoginComponent implements OnInit {
  //
  final LocalDataService localDataService;
  final ServerDataService serverDataService;
  final EventBus eventBus;
  String pass = '';
  String user = 'PBD';
  bool connected = false;

  LoginComponent(this.localDataService, this.serverDataService, this.eventBus);

  @override
  Future<Null> ngOnInit() async {
    String token = localDataService.getToken(user);
    if (token != null) connected = await serverDataService.checkToken(user, token);
    else connected = false;
  }

  void pushEvent(bool c) {
    if (c) eventBus.onEventLog(Event("login"));
    else eventBus.onEventLog(Event("logoff"));
  }

  Future<Null> connect() async {
    print("connect ...");
    String userToken = await serverDataService.connect(user, pass);
    if (userToken != null) {
      localDataService.saveToken(user, userToken);
      print("connection success !");
      connected = true;
    }
    else {
      print("connection error !");
      connected = false;
    }
    pushEvent(connected);
  }

  Future<Null>  disconnect() async {
    print("disconnect...");
    String userToken = await serverDataService.disconnect(user, localDataService.getToken(user));
    print("userToken : " +userToken);
    localDataService.removeToken(user);
    connected = false;
    if (userToken == "XX") localDataService.removeLocal();
    pushEvent(connected);
  }
}