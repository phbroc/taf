import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
import 'dart:html';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart';
import '../app_config.dart';
import '../in_memory_data_service.dart';
import '../message_service.dart';
import '../server_data_service.dart';
import '../local_storage_data_service.dart';
import 'commons.dart';

@Component(
    selector: 'login',
    templateUrl: 'login_component.html',
    styleUrls: ['login_component.css'],
    directives: [coreDirectives, formDirectives],
    providers: [
      ClassProvider(AppConfig),
      FORM_PROVIDERS,
    ]
)

class LoginComponent implements OnInit {
  final InMemoryDataService _inMemoryDataService;
  final AppConfig config;
  final _mockUrlLang = 'api/lang';
  final _mockUrlUser = 'api/user';
  final _mockUrlKey = 'api/key';
  final _mockUrlAll = 'api/all';
  final _headers = {'Content-Type': 'application/json'};

  String title = '';
  String passwordStr = '';
  String passwordChangeStr = '';
  String newPasswordStr = '';
  String newPassRepeatStr = '';
  String repeatErrorStr = '';
  String changeStr = '';
  String connectionStr = '';
  String disconnectionStr = '';
  String keyStr = '';
  String keyUpdateStr = '';
  String requiredErrorStr = '';
  String connectionErrorStr = '';
  String personalKeyStr = '';
  String lookStr = '';
  String maskStr = '';
  String keySetStr = '';
  String keyUnsetStr = '';
  String identificationStr = '';
  String cryptographyStr = '';
  String enabledStr = '';
  String keyFormatErrorStr = '';
  String keyLengthErrorStr = '';
  String keyChangeStr = '';
  String changeDoneStr = '';
  String userStr = '';
  int langId = 0;
  RadioButtonState langChoiceFR = RadioButtonState(true, "0");
  RadioButtonState langChoiceEN = RadioButtonState(false, "1");
  RadioButtonState cryptoChoice16 = RadioButtonState(true, "16");
  RadioButtonState cryptoChoice24 = RadioButtonState(false, "24");
  RadioButtonState cryptoChoice32 = RadioButtonState(false, "32");
  bool connected = false;
  bool newPassWanted = false;
  bool errorForm1 = false;
  bool successForm1 = false;
  String form1Message = '';
  String password = '';
  String newPassword = '';
  String newPassRepeat = '';
  String personalKeyInpMode = 'password';
  String keyUpdateInpMode = 'password';
  String personalKey = '';
  bool newKeyWanted = false;
  String keyUpdate = '';
  int personalKeyLength = 0;
  int keyUpdateLength = 0;
  int preferedKeyLength = 16;
  bool errorForm2 = false;
  bool successForm2 = false;
  String form2Message = '';
  bool cryptoOn = false;
  String user = '';
  late InputElement userInp;
  late InputElement personalKeyInp;
  late InputElement keyUpdateInp;

  LoginComponent(this._inMemoryDataService, this.config) {
    MessageService.doneController.stream.listen((event) {
      if (event.toString() == "local init done") {
        _getUser();
      }
    });
  }

  void langStr() {
    title = config.loginTitle[langId];
    passwordStr = config.personalPass[langId];
    passwordChangeStr = config.passChange[langId];
    newPasswordStr = config.newPersonalPass[langId];
    newPassRepeatStr = config.newPassRepeat[langId];
    repeatErrorStr = config.repeatError[langId];
    changeStr = config.change[langId];
    connectionStr = config.connection[langId];
    disconnectionStr = config.disconnection[langId];
    keyStr = config.personalKey[langId];
    keyUpdateStr = config.keyUpdate[langId];
    requiredErrorStr = config.requiredError[langId];
    connectionErrorStr = config.connectionError[langId];
    personalKeyStr = config.personalKey[langId];
    lookStr = config.look[langId];
    maskStr = config.mask[langId];
    keySetStr = config.keySet[langId];
    keyUnsetStr = config.keyUnset[langId];
    identificationStr = config.identification[langId];
    cryptographyStr = config.cryptography[langId];
    enabledStr = config.enabled[langId];
    keyFormatErrorStr = config.keyFormatError[langId];
    keyLengthErrorStr = config.keyLengthError[langId];
    changeDoneStr = config.changedDone[langId];
    userStr = config.user[langId];
    keyChangeStr = config.keyChange[langId];
  }

  dynamic _extractData(Response resp) => json.decode(resp.body)['data'];

  @override
  void ngOnInit() async {
    langId = await Commons.getLang();
    langStr();
    final responseK = await _inMemoryDataService.get(Uri.parse(_mockUrlKey));
    String? key = _extractData(responseK);
    if ((key != null) && (key != "")) {
      // pour renforcer la sécurité, il ne faut pas afficher automatiquement la clé, juste connaître sa longueur.
      //personalKey = key;
      cryptoOn = true;
      preferedKeyLength = key.length;
      switch (preferedKeyLength) {
        case 16 :
          cryptoChoice16 = RadioButtonState(true, "16");
          break;
        case 24 :
          cryptoChoice24 = RadioButtonState(true, "24");
          break;
        case 32 :
          cryptoChoice32 = RadioButtonState(true, "32");
          break;
      }
    }

    switch (langId) {
      case 0:
        langChoiceFR = RadioButtonState(true, "0");
        langChoiceEN = RadioButtonState(false, "1");
        break;
      case 1:
        langChoiceFR = RadioButtonState(false, "0");
        langChoiceEN = RadioButtonState(true, "1");
        break;
    }

    _getUser();


    if (!connected) {
      userInp = querySelector("#userInp") as InputElement;
      if (userInp != null) {
        userInp.maxLength = 3;
      }
    }

    /*
    else {

    }
    */
  }

  Future<void> _getUser() async {
    final responseU = await _inMemoryDataService.get(Uri.parse(_mockUrlUser));
    final userData = _extractData(responseU);
    user = userData['user'];
    // print("debug... loginComp getUser: $user");
    if (user != config.shareUser) {
      // check identification with token, if is online.
      String? uc = await Commons.getUserConnected();
      if ((uc != null) && (uc != "")) {
        user = uc;
        connected = true;
        MessageService.send("user connected");
      }
      else {
        connected = false;
      }
    }
  }

  void changeLang(int l) async {
    langId = l;
    String lang = "";
    switch (langId) {
      case 0: lang = "FR"; break;
      case 1: lang = "EN"; break;
      default: lang = "FR";
    }
    final response = await _inMemoryDataService.put(Uri.parse("$_mockUrlLang/$lang"));
    langStr();

    MessageService.send("lang changed $langId");
  }

  void changeCryptoLevel(int l) {
    preferedKeyLength = l;
  }


  Future<void> connect() async {
    password = password.trim();
    if (password != '') {
      var bytes = utf8.encode(password);
      var digest = sha256.convert(bytes);
      // print("debug... connect digest $digest");
      final responseC = await ServerDataService.connect(user, digest.toString());
      //print("debug connect ${responseC.statusCode}");
      if (responseC.statusCode == 200) {
        Map jsonData = _extractData(responseC);
        String? token = jsonData['token'];
        String? email = jsonData['email'];
        print("login_component connect");
        if ((email != null) && (token != null) && (token != "")) {
          user = jsonData['user'];

          final responseU = await _inMemoryDataService.put(
              Uri.parse("$_mockUrlUser/$user"),
              headers: _headers,
              body: json.encode({'token': token, 'email': email})
          );
          LocalStorageDataService.saveUser(user, token, email);
          connected = true;
          errorForm1 = false;
          form1Message = '';
          password = '';

          MessageService.send("user connected");
        }
        else {
          connected = false;
          errorForm1 = true;
          form1Message = connectionErrorStr;
        }
      }
      else {
        connected = false;
        errorForm1 = true;
        form1Message = connectionErrorStr;
      }
    }
    else {
      errorForm1 = true;
      form1Message = requiredErrorStr;
    }
  }

  Future<void> disconnect() async {
    final responseU = await _inMemoryDataService.get(Uri.parse(_mockUrlUser));
    final userData = _extractData(responseU);
    String? token = userData['token'];
    if ((token != null) && (token != '')) {
      final responseD = await ServerDataService.disconnect(user, token);
      if (responseD.statusCode == 200) {
        Map jsonData = _extractData(responseD);
        bool success = jsonData['success'];
        final responseZ = await _inMemoryDataService.delete(Uri.parse(_mockUrlAll));
        LocalStorageDataService.resetUser();
        LocalStorageDataService.resetToknows();
        // bizarre il semble que cette action n'a pas fonctionné, la date de synchro n'est pas réinitialisé lors de la connexion suivante.
        LocalStorageDataService.resetDayHourSync();
      }
    }
    user = config.shareUser;
    final responseV = await _inMemoryDataService.put(Uri.parse("$_mockUrlUser/$user"),
        headers: _headers,
        body: json.encode({'token': '', 'email': ''})
    );
    final responseK = await _inMemoryDataService.put(Uri.parse(_mockUrlKey));

    connected = false;
    personalKey = '';
    cryptoOn = false;

    MessageService.send("user disconnected");
  }

  Future<void> passwordChange() async {
    password = password.trim();
    newPassword = newPassword.trim();
    newPassRepeat = newPassRepeat.trim();
    if ((newPassword != '') && (newPassword != newPassRepeat)) {
      errorForm1 = true;
      form1Message = repeatErrorStr;
    }
    else if ((password != '') && (newPassword != '')) {
      var bytesP = utf8.encode(password);
      var digestP = sha256.convert(bytesP);
      var bytesN = utf8.encode(newPassword);
      var digestN = sha256.convert(bytesN);

      final responseU = await _inMemoryDataService.get(Uri.parse(_mockUrlUser));
      final userData = _extractData(responseU);
      String? token = userData['token'];
      if ((token != null) && (token != '')) {
        final responseP = await ServerDataService.changePassword(user, digestP.toString(), digestN.toString(), token);
        if (responseP.statusCode == 200) {
          Map jsonData = _extractData(responseP);
          bool success = jsonData['success'];
          if (success) {
            successForm1 = true;
            form1Message = changeDoneStr;
            password = '';
            newPassword = '';
            newPassWanted = false;
          }
          else {
            errorForm1 = true;
            form1Message = connectionErrorStr;
          }
        }
        else {
          errorForm1 = true;
          form1Message = connectionErrorStr;
        }
      }
      else {
        errorForm1 = true;
        form1Message = connectionErrorStr;
      }
    }
  }

  void lookPersonalKey() {
    personalKeyInpMode = 'text';
  }

  void maskPersonalKey() {
    personalKeyInpMode = 'password';
  }

  void lookKeyUpdate() {
    keyUpdateInpMode = 'text';
  }

  void maskKeyUpdate() {
    keyUpdateInpMode = 'password';
  }

  void keyControl(String? pk, int num) {
    if (pk != null) {
      if (num == 1) {
        personalKeyInp = querySelector("#personalKeyInp") as InputElement;
        if (personalKeyInp != null) {
          personalKeyInp.maxLength = preferedKeyLength;
        }
        personalKeyLength = pk.length;
      }
      else if (num == 2) {
        keyUpdateInp = querySelector("#keyUpdateInp") as InputElement;
        if (keyUpdateInp != null) {
          keyUpdateInp.maxLength = preferedKeyLength;
        }
        keyUpdateLength = pk.length;
      }

      if (pk != '') {
        //RegExp control = RegExp(r'[^A-Za-z0-9\_\-]');
        RegExp control = RegExp(r'\s');
        RegExpMatch? match = control.firstMatch(pk);
        if ((match != null) && (match[0] != "")) {
          errorForm2 = true;
          form2Message = keyFormatErrorStr;
        }
        else {
          if (pk.length != preferedKeyLength) {
            errorForm2 = true;
            form2Message = keyLengthErrorStr + preferedKeyLength.toString();
          }
          else {
            errorForm2 = false;
            form2Message = "";
          }

        }
      }
      else {
        errorForm2 = false;
        form2Message = "";
      }
    }
  }

  void putCryptoOn() async {
    personalKey = personalKey.trim();
    if (personalKey != '') {
      final response = await _inMemoryDataService.put(Uri.parse("$_mockUrlKey/$personalKey"));
      personalKey = '';
      cryptoOn = true;
      errorForm2 = false;
      form2Message = '';
    }
    else {
      errorForm2 = true;
      form2Message = requiredErrorStr;
    }
  }

  void putCryptoOff() async {
    final response = await _inMemoryDataService.put(Uri.parse(_mockUrlKey));
    personalKey = '';
    cryptoOn = false;
  }

  void keyChange() async {
    personalKey = personalKey.trim();
    keyUpdate = keyUpdate.trim();
    if ((personalKey != '') && (keyUpdate != '')) {
      personalKey = '';
      keyUpdate = '';
      errorForm2 = false;
      form2Message = '';
    }
    else {
      errorForm2 = true;
      form2Message = requiredErrorStr;
    }
  }
}