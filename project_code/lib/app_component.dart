import 'package:ngdart/angular.dart';
import 'package:ngrouter/ngrouter.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'app_config.dart';
import 'dart:convert';
import 'dart:html';
import 'in_memory_data_service.dart';
import 'local_storage_data_service.dart';
import 'server_data_service.dart';
import 'message_service.dart';
import 'src/routes.dart';
import 'src/toknow/toknow.dart';
import 'src/commons.dart';

const appConfigOpaqueToken = OpaqueToken('app.config');

@Component(
  selector: 'my-app',
  templateUrl: 'app_component.html',
  providers: [
    Provider(appConfigOpaqueToken, useFactory:tafConfigFactory),
    ClassProvider(InMemoryDataService),
    ClassProvider(LocalStorageDataService),
    ClassProvider(ServerDataService),
    ClassProvider(MessageService),
  ],
  directives: [
    coreDirectives,
    routerDirectives
  ],
  exports: [RoutePaths, Routes],
)

class AppComponent implements OnInit {
  String title = '';
  String homeLinkStr = '';
  String userLinkStr = '';
  String loginStr = '';
  String onLineStr = '';
  String offLineStr = '';
  String synchronizedStr = '';
  final InMemoryDataService _inMemoryDataService;
  late String user;
  String shareUser = '';
  final _headers = {'Content-Type': 'application/json'};
  final _mockUrlTag = 'api/tag';
  final _mockUrlAllToknows = 'api/toknows';
  final _mockUrlToknow = 'api/toknow';
  final _mockUrlLang = 'api/lang';
  final _mockUrlUser = "api/user";
  bool connected = false;
  bool isOnLine = false;
  bool synchroOn = false;
  bool initDone = false;
  DateTime dayhourSync = DateTime(2025, 1, 1);
  static final datePromptFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
  String promptDayhourSync = '';

  AppComponent(
      @Inject(appConfigOpaqueToken) AppConfig config,
      this._inMemoryDataService) {

    user = config.shareUser;

    window.onOffline.listen((Event e) {
      isOnLine = false;
    });

    window.onOnline.listen((Event e) {
      isOnLine = true;
      _synchroServer();
    });

    MessageService.doneController.stream.listen((event) async {
      if ((event.toString() == "post done") || (event.toString() == "put done")) {
        if (initDone) _saveLocal();
        if ((connected) && (isOnLine) && (!synchroOn)) {
          bool success = await _synchroServer();
        }
      }
      else if (event.toString() == "user connected") {
        connected = true;
        isOnLine = true;
        // refresh user
        final responseU = await _inMemoryDataService.get(Uri.parse(_mockUrlUser));
        final userData = _extractData(responseU);
        user = userData['user'];
        bool success = await _synchroServer();
      }
      else if (event.toString() == "user disconnected") {
        connected = false;
        // refresh user
        final responseU = await _inMemoryDataService.get(Uri.parse(_mockUrlUser));
        final userData = _extractData(responseU);
        user = userData['user'];
      }
      else if (event.toString().substring(0, 12) == "lang changed") {
        int langId = int.parse(event.toString().substring(13, 14));
        title = config.appTitle[langId];
        homeLinkStr = config.homeLink[langId];
        userLinkStr = config.userLink[langId];
      }
      else if (event.toString() == "local init done") {
        initDone = true;
      }
    });
  }

  @override
  void ngOnInit() async {
    ServerDataService.setup(
        tafConfigFactory().apiUrl,
        tafConfigFactory().userUrl,
        tafConfigFactory().toknowUrl
    );

    final responseL = await _inMemoryDataService.put(Uri.parse("$_mockUrlLang/FR"));
    int langId = 0;

    title = tafConfigFactory().appTitle[langId];
    homeLinkStr = tafConfigFactory().homeLink[langId];
    userLinkStr = tafConfigFactory().userLink[langId];
    onLineStr = tafConfigFactory().onLine[langId];
    offLineStr = tafConfigFactory().offLine[langId];
    synchronizedStr = tafConfigFactory().synchronized[langId];
    shareUser = tafConfigFactory().shareUser;

    LocalStorageDataService.setup(tafConfigFactory().localStName);

    try {
      // check if user is connected (like in login component)
      Map<String, String>? ul = LocalStorageDataService.getUser();
      // ... if ul is not shareUser...
      if ((ul != null) && (ul['user'] != tafConfigFactory().shareUser)) {
        user = ul['user']!;
        String token = ul['token']!;
        String email = ul['email']!;
        final responseU = await _inMemoryDataService.put(Uri.parse("$_mockUrlUser/$user"),
            headers: _headers,
            body: json.encode({'token': token, 'email': email})
        );
        String? uc = await Commons.getUserConnected();
        if ((uc == user)) {
          connected = true;
          isOnLine = true;
        }
      }
      else {
        user = tafConfigFactory().shareUser;
        final responseU = await _inMemoryDataService.put(Uri.parse("$_mockUrlUser/$user"),
            headers: _headers,
            body: json.encode({'token': '', 'email': ''})
        );
      }
    } catch (e) {
      // _handleError(e);
      Map<String, String>?  ul = LocalStorageDataService.getUser();
      if ((ul != null) && (ul['user'] != tafConfigFactory().shareUser)) {
        user = ul['user']!;
        String token = ul['token']!;
        String email = ul['email']!;
        final responseU = await _inMemoryDataService.put(Uri.parse("$_mockUrlUser/$user"),
            headers: _headers,
            body: json.encode({'token': token, 'email': email})
        );
      }
      else {
        user = tafConfigFactory().shareUser;
        final responseU = await _inMemoryDataService.put(Uri.parse("$_mockUrlUser/$user"),
            headers: _headers,
            body: json.encode({'token': '', 'email': ''})
        );
      }
    }

    try {
      if (connected) {
        // final responseU = await _inMemoryDataService.put(Uri.parse("$_mockUrlUser/$user"));
        isOnLine = true;
        bool success = await _synchroServer();
      }

      final List<Toknow> startToknows = await LocalStorageDataService.loadToknows();
      for (var toknow in startToknows) {
        var responseT = await _inMemoryDataService.post(
            Uri.parse(_mockUrlToknow),
            headers: _headers,
            body: json.encode(toknow.toJson())
        );
      }

      MessageService.send("local init done");
    } catch (e) {
      throw _handleError(e);
    }
  }

  dynamic _extractData(Response resp) => json.decode(resp.body)['data'];

  void _saveLocal() async {
    try {
      // local save
      final responseAllToknows = await _inMemoryDataService.get(Uri.parse(_mockUrlAllToknows));
      final List<Toknow> allToknows = (_extractData(responseAllToknows) as List)
          .map((json) => Toknow.fromJson(json))
          .toList();
      LocalStorageDataService.saveToknows(allToknows);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> _synchroServer() async {
    synchroOn = true;
    String? dhs = LocalStorageDataService.getDayHourSync();
    if (dhs != null) {
      dayhourSync = DateTime.parse(dhs);
    }
    if (user != tafConfigFactory().shareUser) {
      final responseU = await _inMemoryDataService.get(Uri.parse("$_mockUrlUser/$user"));
      final userData = _extractData(responseU);
      String? token = userData['token'];
      if (token != null) {
        final responseSyncToknows = await _inMemoryDataService.get(Uri.parse("$_mockUrlAllToknows/since/${dayhourSync.toIso8601String()}"));
        final List<Toknow> syncToknows = (_extractData(responseSyncToknows) as List)
            .map((json) => Toknow.fromJson(json))
            .toList();
        final responseS = await ServerDataService.synchroToknowList(syncToknows, dayhourSync, token);

        if (responseS.statusCode == 200) {
          final List<Toknow> syncToknowsAfter =  (_extractData(responseS)["toknows"] as List)
              .map((json) => Toknow.fromJson(json))
              .toList();

          for (var toknow in syncToknowsAfter) {
            // check for toknow to delete because of version XX
            // print("debug toknow after ${toknow.id}");
            if (toknow.version == 'XX') {
              await _inMemoryDataService.delete(
                  Uri.parse(_mockUrlToknow),
                  headers: _headers,
                  body: json.encode(toknow.toJson())
              );
            }
            else {
              // check if PUT or POST
              final toknowExists = await _inMemoryDataService.get(Uri.parse("$_mockUrlToknow/${toknow.id}"));
              if (_extractData(toknowExists) != null) {
                await _inMemoryDataService.put(
                    Uri.parse(_mockUrlToknow),
                    headers: _headers,
                    body: json.encode(toknow.toJson())
                );
              }
              else {
                await _inMemoryDataService.post(
                    Uri.parse(_mockUrlToknow),
                    headers: _headers,
                    body: json.encode(toknow.toJson())
                );
              }
            }
          }
          _saveLocal();
          dayhourSync = DateTime.now();
          LocalStorageDataService.saveDayHourSync(dayhourSync.toIso8601String());
          synchroOn = false;
          promptDayhourSync = datePromptFormat.format(dayhourSync);
          return true;
        }
        else {
          synchroOn = false;
          return false;
        }
      }
      else {
        synchroOn = false;
        return false;
      }
    }
    else {
      synchroOn = false;
      return false;
    }
  }



  Exception _handleError(dynamic e) {
    print('App component error; cause: $e !'); // for demo purposes only
    return Exception('App component error; cause: $e !');
  }
}