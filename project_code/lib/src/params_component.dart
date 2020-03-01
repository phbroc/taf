import 'package:angular_components/angular_components.dart';
import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart';

//import 'package:angular_forms/angular_forms.dart'; serait utile si j'ajoute formDirectives dans les directives

import 'package:taf/local_data_service.dart';
import 'package:taf/server_data_service.dart';
import 'dart:async';
import '../event_bus.dart';
import 'dart:html';
import 'app_config.dart';
import '../in_memory_data_service.dart';

@Component(
  selector: 'params',
  styleUrls: ['params_component.css'],
  templateUrl: 'params_component.html',
  directives: [
    coreDirectives,
    // ajouté ci-dessous pour form validation
    formDirectives,
    MaterialInputComponent,
    MaterialFabComponent,
    MaterialIconComponent,
    materialInputDirectives,
  ],
  providers: [
    FactoryProvider(AppConfig, appConfigFactory),
  ]
)

class ParamsComponent implements OnInit, OnDestroy {
  //
  final LocalDataService localDataService;
  final ServerDataService serverDataService;
  final EventBus eventBus;
  String pass = '';
  String user;
  bool connected = false;
  String cryptoKey = '';

  Control ckeyControl = Control('');

  ParamsComponent(AppConfig config, this.localDataService, this.serverDataService, this.eventBus):user=config.user;

  @override
  Future<Null> ngOnInit() async {
    String token = localDataService.getToken(user);
    if (token != null) connected = await serverDataService.checkToken(user, token);
    else connected = false;

    cryptoKey = InMemoryDataService.getCryptoKey();

    if (cryptoKey != null) {
      this.ckeyControl = Control(cryptoKey, validateCkey);
    }
    else this.ckeyControl = Control('', validateCkey);
  }

  @override
  void ngOnDestroy() {
    // implement ngOnDestroy, avant de quitter le composant
    print('onDestroy Params...');
    InMemoryDataService.setCryptoKey(cryptoKey);
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
    if (userToken == "XX") localDataService.removeTodoList(user);
    pushEvent(connected);
  }

  // my first custom control!
  Map<String, dynamic> validateCkey(AbstractControl c) {
    Map<String, dynamic> errors = {};
    // print('validateCkey: ${c.value}');
    if (c.value != null) {
      if (c.value.trim().length > 0) {
        RegExp expTag = RegExp(r"^[a-zA-Z0-9]+$");
        Match matches = expTag.firstMatch(c.value.trim());
        if (matches == null) {
          errors['Le format de la clé est incorrect. Caractères autorisés : alphanumériques'] = true;
        }
      }
    }
    return errors;
  }

}