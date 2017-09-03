import 'package:angular_components/angular_components.dart';
import 'package:angular2/angular2.dart';
import 'package:taf/local_data_service.dart';
import 'package:taf/server_data_service.dart';
import 'dart:async';

@Component(
  selector: 'login',
  styleUrls: const ['login_component.css'],
  templateUrl: 'login_component.html',
  directives: const [
    CORE_DIRECTIVES,
    FORM_DIRECTIVES,
    materialDirectives,
  ],
)

class LoginComponent implements OnInit {
  //
  final LocalDataService localDataService;
  final ServerDataService serverDataService;
  String pass = '';
  String user = 'PBD';
  bool connected = false;

  // gestion d'un événement à pousser vers le parent avec ce stream.
  final _eventStreamCtl = new StreamController<bool>();
  @Output()
  Stream<bool> get eventStream => _eventStreamCtl.stream;

  LoginComponent(this.localDataService, this.serverDataService);

  @override
  Future<Null> ngOnInit() async {
    connected = await serverDataService.checkToken(user, localDataService.getToken(user));
  }

  void pushEvent(bool c) {
    // print(s);
    _eventStreamCtl.add(c);
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
    localDataService.saveToken(user, "");
    connected = false;
    pushEvent(connected);
  }
}