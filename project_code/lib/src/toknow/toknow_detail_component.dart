import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';
import 'package:ngrouter/ngrouter.dart';
import 'package:http/http.dart';
import 'package:taf2/encrypt_data_service.dart';
import 'toknow.dart';
import 'dart:async';
import 'dart:html';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../in_memory_data_service.dart';
import '../../encrypt_data_service.dart';
import '../../local_storage_data_service.dart';
import '../route_paths.dart';
import '../../app_config.dart';
import '../commons.dart';

@Component(
    selector: 'toknow-detail',
    templateUrl: 'toknow_detail_component.html',
    styleUrls: ['toknow_detail_component.css'],
    directives: [coreDirectives, formDirectives],
    providers: [
      ClassProvider(AppConfig),
      ClassProvider(EncryptDataService)
    ]
)

class ToknowDetailComponent implements OnInit, OnActivate {
  final InMemoryDataService _inMemoryDataService;
  final EncryptDataService _encryptDataService;
  final AppConfig config;
  final _headers = {'Content-Type': 'application/json'};
  final _mockUrlToknow = 'api/toknow';
  final _mockUrlAllToknows = 'api/toknows';
  final _mockUrlKey = 'api/key';
  final _mockUrlUser = 'api/user';
  final Location _location;
  static final datePromptFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
  static final dateSmallPromptFormat = DateFormat('yyyy-MM-dd');
  static final num2digitFormat = NumberFormat("00");
  String promptDayhour = '';
  Toknow? toknow;
  String endDay = '';
  String endHour = '';
  String endMinute = '';
  String titleStr = '';
  String descriptionStr = '';
  String tagStr = '';
  String cryptoStr = '';
  String quickStr = '';
  String doneStr = '';
  String endStr = '';
  String saveStr = '';
  String backStr = '';
  String dateStr = '';
  String shareStr = '';
  String titleRequiredStr = '';
  int langId = 0;
  bool cryptoOn = false;
  bool connected = false;
  late String user;
  late final String? iv;
  late final String? key;
  String toknowUser = '';
  bool shared = false;
  bool errorForm1 = false;
  String form1Message = '';

  ToknowDetailComponent(this._inMemoryDataService, this._encryptDataService, this._location, this.config);

  dynamic _extractData(Response resp) => json.decode(resp.body)['data'];

  Future<void> _getToknow(String id) async {
    try {
      final response = await _inMemoryDataService.get(Uri.parse("$_mockUrlToknow/$id"));
      if (_extractData(response) != null) {
        toknow = Toknow.fromJson(_extractData(response));
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  void ngOnInit() async {
    langId = await Commons.getLang();
    titleStr = config.title[langId];
    descriptionStr = config.description[langId];
    tagStr = config.tag[langId];
    cryptoStr = config.crypto[langId];
    quickStr = config.quick[langId];
    doneStr = config.done[langId];
    endStr = config.end[langId];
    saveStr = config.save[langId];
    backStr = config.back[langId];
    dateStr = config.date[langId];
    shareStr = config.share[langId];
    titleRequiredStr = config.titleRequired[langId];
  }

  @override
  void onActivate(_, RouterState current) async {
    final id = getId(current.parameters);
    if (id != null) {
      await _getToknow(id);
      if(toknow != null) {
        // this is a way to deal with Datetime?
        final dh = toknow?.dayhour;
        promptDayhour = datePromptFormat.format(dh!);
        if (toknow?.end != null) {
          final de = toknow!.end;
          endDay = dateSmallPromptFormat.format(de!);
          endHour = num2digitFormat.format(de.hour);
          endMinute = num2digitFormat.format(de.minute);
        }
        // si le toknow est SHR alors il faut interdire le mode crypto.
        toknowUser = toknow!.id.substring(0, 3);
        if (toknowUser != 'SHR') {
          final responseU = await _inMemoryDataService.get(Uri.parse(_mockUrlUser));
          final userData = _extractData(responseU);
          user = userData['user'];
          if (user != config.shareUser) {
            connected = true;
            final responseK = await _inMemoryDataService.get(Uri.parse(_mockUrlKey));
            key = _extractData(responseK);

            // connaissant la clé, si le toknow est crypté, il faut le décrypter maintenant
            if ((key != null) && (key != "")) {
              cryptoOn = true;
              _encryptDataService.init(key!);
              if ((toknow!.crypto) && (toknow!.description != null) && (toknow!.description != "")) {
                String description = _encryptDataService.decryptData(toknow!.description!);
                toknow!.description = description;
              }
            }
            else {
              cryptoOn = false;
            }
          }
          else {
            cryptoOn = false;
          }
        }
        else {
          cryptoOn = false;
          shared = true;
        }
      }
    }
  }

  void goBack() => _location.back();

  Future<void> save() async {
    String title = toknow!.title.trim();
    if (title != "") {
      try {
        String tagName = toknow!.tag.trim();
        if (tagName == "") {
          tagName = "notag";
        }

        int color = Commons.stringToModuloIndex(tagName, 80);

        if (endDay.isNotEmpty) {
          if (endHour.isNotEmpty) {
            if (endMinute.isNotEmpty) {
              toknow!.end = DateTime.tryParse("$endDay $endHour:$endMinute:00");
            }
            else {
              toknow!.end = DateTime.tryParse("$endDay $endHour:00:00");
            }
          }
          else {
            toknow!.end = DateTime.tryParse("$endDay 23:45:00");
          }
        }
        else {
          toknow!.end = null;
        }
        // special workflow when user wants to share a personal toknow
        if ((toknowUser != "SHR") && (shared)) {
          // create a new toknow for SHR user
          final tempUser = config.shareUser;
          final responseT = await _inMemoryDataService.put(Uri.parse("$_mockUrlUser/$tempUser"));

          String sharedEnd = "";
          if (toknow!.end != null) sharedEnd = toknow!.end!.toIso8601String();
          // special case, two toknows are managed at the same time, don't send message for the first one
          final responseN = await _inMemoryDataService.post(
              Uri.parse(_mockUrlToknow),
              headers: _headers,
              body: json.encode({'id': null,
                'title': toknow!.title,
                'description': toknow!.description,
                'done': toknow!.done,
                'tag': toknow!.tag,
                'color' : color,
                'end': sharedEnd,
                'priority': toknow!.priority,
                'quick': toknow!.quick,
                'crypto': toknow!.crypto,
                'nomessage': 'first'
              })
          );

          final responseU = await _inMemoryDataService.put(Uri.parse("$_mockUrlUser/$user"));

          final url = '$_mockUrlToknow/${toknow!.id}';
          toknow!.dayhour = DateTime.now();
          toknow!.version = "DD";
          final tokDel = toknow!.toJson();
          final responseD = _inMemoryDataService.put(Uri.parse(url),
              headers: _headers,
              body: jsonEncode(tokDel));
        }
        else {
          final url = '$_mockUrlToknow/${toknow!.id}';
          // increment version
          int? version = int.tryParse(toknow!.version);
          if ((version != null) && (version >= 0)) {
            if (version < 99) {
              version++;
              if (version < 10) {
                toknow!.version = "0$version";
              }
              else {
                toknow!.version = version.toString();
              }
            }
          }
          toknow!.color = color;
          toknow!.dayhour = DateTime.now();
          // si le toknow est à crypter il faut le faire maintenant
          if ((cryptoOn) && (toknow!.crypto) && (toknow!.description != null) && (toknow!.description != "")) {
            String description = _encryptDataService.encryptData(toknow!.description!);
            toknow!.description = description;
          }
          final tokPut = toknow!.toJson();
          final response = await _inMemoryDataService.put(Uri.parse(url),
              headers: _headers,
              body: jsonEncode(tokPut));
        }
      } catch (e) {
        throw _handleError(e);
      }
      goBack();
    }
    else {
      errorForm1 = true;
      form1Message = titleRequiredStr;
    }


  }

  Exception _handleError(dynamic e) {
    print('Detail component error; cause: $e !'); // for demo purposes only
    return Exception('Detail component error; cause: $e !');
  }
}