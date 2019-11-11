import 'package:angular_components/angular_components.dart';
import 'package:angular/angular.dart';
//import 'package:angular2/platform/common.dart';
import 'package:angular_router/angular_router.dart';
import '../route_paths.dart';
// ajouté ci-dessous pour form validation
import 'package:angular_forms/angular_forms.dart';
import 'package:intl/intl.dart';
//import 'dart:async';
import 'todo.dart';
import 'package:taf/in_memory_data_service.dart';
import '../utils/converter.dart';
import '../utils/cryptographie.dart';
import '../tag_list/tag.dart';
import '../../event_bus.dart';

@Component(
  selector: 'todo-detail',
  styleUrls: ['todo_detail_component.css'],
  templateUrl: 'todo_detail_component.html',
  directives: [
    coreDirectives,
    // ajouté ci-dessous pour form validation
    formDirectives,
    MaterialInputComponent,
    MaterialButtonComponent,
    materialInputDirectives,
  ],
)

class TodoDetailComponent implements OnActivate, OnDestroy {
  Todo todoItem;

  final Location _location;

  final nformat = NumberFormat("000000");
  final dformat = DateFormat('yyyy-MM-dd HH:mm:ss');
  final EventBus eventBus;

  Control endControl;

  String dayStr;
  bool todoChanged = false;

  TodoDetailComponent(this._location, this.eventBus) {

  }

  @override
  void onActivate(_, RouterState current) {
    final String id = getId(current.parameters);
    if (id != null) {
      todoItem = InMemoryDataService.giveById(id);
      print("detail..." + todoItem.title);
      if (todoItem.end != null) {
        String dstr = todoItem.end.toString();
        String aaaa = dstr.substring(0,4);
        String mm = dstr.substring(5,7);
        String jj = dstr.substring(8,10);
        String dstrjma = jj + "/" + mm + "/" + aaaa;
        print("date... " + dstrjma);
        // cette subtilité c'est à l'init du control qu'on peut passer une valeur!
        this.endControl = Control(dstrjma, validateDate);
      }
      else {
        this.endControl = Control('', validateDate);
      }
    }
    todoChanged = false;
  }

  @override
  void ngOnDestroy() {
    // implement ngOnDestroy, avant de quitter l'édition dire que ça a changé si c'est le cas
    if (todoChanged) eventBus.onEventTodoChanged("todochanged");
  }

  // my first custom control!
  Map<String, dynamic> validateDate(AbstractControl c) {
    Map<String, dynamic> errors = {};
    //print('validateDate: ${c.value}');

    if ((c.value.trim().length != 10) && (c.value.trim().length > 0)) {
      errors['Le format de date est sur 10 caractères JJ/MM/AAAA.'] = true;
      dayStr = "";
    }
    else if (c.value.trim().length > 0) {
      // ce regex doit fonctionner avec JJ/MM/AAAA 00:00:00, l'heure étant en option.
      RegExp expTag = new RegExp(r"(^(([0-2]\d|[3][0-1])\/([0]\d|[1][0-2])\/[2][0]\d{2})$|^(([0-2]\d|[3][0-1])\/([0]\d|[1][0-2])\/[2][0]\d{2}\s([0-1]\d|[2][0-3])\:[0-5]\d\:[0-5]\d)$)");
      Match matches = expTag.firstMatch(c.value.trim());
      if (matches == null) {
        errors['Le format de date doit respecter JJ/MM/AAAA.'] = true;
        dayStr = "";
      }
      else {
        String aaaa = c.value.trim().substring(6,10);
        String mm = c.value.trim().substring(3,5);
        String jj = c.value.trim().substring(0,2);
        String dstr = aaaa+"-"+mm+"-"+jj;
        print("parsing... " + dstr);
        try {
          var d = DateTime.parse(dstr);
          dayStr = giveWeekDay(d.weekday);
        }
        catch (exception) {
          errors['La date '+dstr+' est invalide.'] = true;
          dayStr = "";
        }
      }
    }
    else dayStr = "";
    return errors;
  }

  void goBack() => _location.back();

  void onChanged() {
    // print("onChanged...");
    var now = DateTime.now();
    todoItem.dayhour = dformat.format(now);
    todoChanged = true;
  }

  void onTagChanged() {
    var now = DateTime.now();
    todoItem.dayhour = dformat.format(now);
    todoChanged = true;

    if (todoItem.tag != "") {
      todoItem.color = Converter.stringToModuloIndex(todoItem.tag, 80) +1;
      InMemoryDataService.updateTagList(Tag(todoItem.tag, todoItem.color));
    }
    else todoItem.color = 0;
  }

  void onDescriptionChanged() {
    print("onDescriptionChanged...");
    var now = DateTime.now();
    todoItem.dayhour = dformat.format(now);
    todoChanged = true;

    // rechercher s'il y a un mot à encrypter
    String s = Cryptographie.findStringToEncrypt(todoItem.description);
    print("mot à encrypter: "+s+".");
  }

  void onEndChanged() {
    print("onEndChanged... " + endControl.value);
    var now = DateTime.now();
    todoItem.dayhour = dformat.format(now);
    todoChanged = true;

    if (endControl.value == "") todoItem.end = null;
    else if (endControl.valid) {
      String aaaa = endControl.value.trim().substring(6,10);
      String mm = endControl.value.trim().substring(3,5);
      String jj = endControl.value.trim().substring(0,2);
      String dstr = aaaa+"-"+mm+"-"+jj+" 23:59:59";
      try {
        todoItem.end = DateTime.parse(dstr);
      }
      catch (exception) {
        print("error parsing date "+dstr);
      }
    }
  }

  DateTime todayEnds() {
    var now = DateTime.now();
    String aaaa = now.year.toString();
    String mm = now.month.toString();
    if (mm.length == 1) mm = "0"+mm;
    String jj = now.day.toString();
    if (jj.length == 1) jj = "0"+jj;
    String dstr = aaaa+"-"+mm+"-"+jj+" 23:59:59";
    return DateTime.parse(dstr);
  }

  String formatDateStr(DateTime d) {
    String aaaa = d.year.toString();
    String mm = d.month.toString();
    if (mm.length == 1) mm = "0"+mm;
    String jj = d.day.toString();
    if (jj.length == 1) jj = "0"+jj;
    String dstr = jj+"/"+mm+"/"+aaaa;
    return dstr;
  }

  String giveWeekDay(int d) {
    String retStr;
    switch(d) {
      case 1: retStr = "lundi"; break;
      case 2: retStr = "mardi"; break;
      case 3: retStr = "mercredi"; break;
      case 4: retStr = "jeudi"; break;
      case 5: retStr = "vendredi"; break;
      case 6: retStr = "samedi"; break;
      case 7: retStr = "dimanche"; break;
      default: retStr = "error"; break;
    }
    return retStr;
  }

  void endsJ() {
    var today = todayEnds();
    todoItem.end = today;
    String dstrjma = formatDateStr(today);
    // cette subtilité init du control pour passer une valeur!
    this.endControl = Control(dstrjma, validateDate);
  }

  void endsPlusOne() {
    DateTime newEnd;
    if (todoItem.end == null) {
      newEnd = todayEnds();
    }
    else {
      newEnd = todoItem.end;
    }
    // print("add 1 day to ... "+newEnd.toString()+"...");
    newEnd = newEnd.add(Duration(days: 1));
    //print("new end ... "+newEnd.toString()+".");
    todoItem.end = newEnd;
    String dstrjma = formatDateStr(newEnd);
    // cette subtilité init du control pour passer une valeur!
    this.endControl = Control(dstrjma, validateDate);
  }

  void endsMinusOne() {
    DateTime newEnd;
    if (todoItem.end == null) {
      newEnd = todayEnds();
    }
    else {
      newEnd = todoItem.end;
    }
    // print("add 1 day to ... "+newEnd.toString()+"...");
    newEnd = newEnd.subtract(Duration(days: 1));
    //print("new end ... "+newEnd.toString()+".");
    todoItem.end = newEnd;
    String dstrjma = formatDateStr(newEnd);
    // cette subtilité init du control pour passer une valeur!
    this.endControl = Control(dstrjma, validateDate);
  }

  void endsPlusSeven() {
    DateTime newEnd;
    if (todoItem.end == null) {
      newEnd = todayEnds();
    }
    else {
      newEnd = todoItem.end;
    }
    // print("add 1 day to ... "+newEnd.toString()+"...");
    newEnd = newEnd.add(Duration(days: 7));
    //print("new end ... "+newEnd.toString()+".");
    todoItem.end = newEnd;
    String dstrjma = formatDateStr(newEnd);
    // cette subtilité init du control pour passer une valeur!
    this.endControl = Control(dstrjma, validateDate);
  }




}



