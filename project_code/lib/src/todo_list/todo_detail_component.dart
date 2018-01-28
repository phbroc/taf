import 'package:angular_components/angular_components.dart';
import 'package:angular/angular.dart';
//import 'package:angular2/platform/common.dart';
import 'package:angular_router/angular_router.dart';
// ajouté ci-dessous pour form validation
import 'package:angular_forms/angular_forms.dart';
import 'package:intl/intl.dart';
//import 'dart:async';
import 'todo.dart';
import 'package:taf/in_memory_data_service.dart';
import '../utils/converter.dart';
import '../tag_list/tag.dart';

@Component(
  selector: 'todo-detail',
  styleUrls: const ['todo_detail_component.css'],
  templateUrl: 'todo_detail_component.html',
  directives: const [
    CORE_DIRECTIVES,
    materialDirectives,
    // ajouté ci-dessous pour form validation
    formDirectives,
  ],
)

class TodoDetailComponent implements OnInit {
  @Input()
  Todo todoItem;

  final Location _location;
  final RouteParams _routeParams;

  final nformat = new NumberFormat("000000");
  final dformat = new DateFormat('yyyy-MM-dd HH:mm:ss');

  Control endControl;

  TodoDetailComponent(this._location, this._routeParams) {

  }

  // my first custom control!
  Map<String, dynamic> validateDate(AbstractControl c) {
    Map<String, dynamic> errors = {};
    //print('validateDate: ${c.value}');

    if ((c.value.trim().length != 10) && (c.value.trim().length > 0)) {
      errors['Le format de date est sur 10 caractères JJ/MM/AAAA.'] = true;
    }
    else if (c.value.trim().length > 0) {
      // ce regex doit fonctionner avec JJ/MM/AAAA 00:00:00, l'heure étant en option.
      RegExp expTag = new RegExp(r"(^(([0-2]\d|[3][0-1])\/([0]\d|[1][0-2])\/[2][0]\d{2})$|^(([0-2]\d|[3][0-1])\/([0]\d|[1][0-2])\/[2][0]\d{2}\s([0-1]\d|[2][0-3])\:[0-5]\d\:[0-5]\d)$)");
      Match matches = expTag.firstMatch(c.value.trim());
      if (matches == null) {
        errors['Le format de date doit respecter JJ/MM/AAAA.'] = true;
      }
      else {
        String aaaa = c.value.trim().substring(6,10);
        String mm = c.value.trim().substring(3,5);
        String jj = c.value.trim().substring(0,2);
        String dstr = aaaa+"-"+mm+"-"+jj;
        print("parsing... " + dstr);
        try {
          DateTime.parse(dstr);
        }
        catch (exception) {
          errors['La date '+dstr+' est invalide.'] = true;
        }
      }
    }
    return errors;
  }

  void ngOnInit() {
    var id = _routeParams.get('id');
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
        this.endControl = new Control(dstrjma, validateDate);
      }
      else {
        this.endControl = new Control('', validateDate);
      }
    }
  }

  void goBack() => _location.back();

  void onChanged() {
    print("onChanged...");
    var now = new DateTime.now();
    todoItem.dayhour = dformat.format(now);
  }

  void onTagChanged() {
    var now = new DateTime.now();
    todoItem.dayhour = dformat.format(now);

    if (todoItem.tag != "") {
      todoItem.color = Converter.stringToModuloIndex(todoItem.tag, 80) +1;
      InMemoryDataService.updateTagList(new Tag(todoItem.tag, todoItem.color));
    }
    else todoItem.color = 0;
  }

  void onEndChanged() {
    print("onEndChanged... " + endControl.value);
    if (endControl.valid) {
      String aaaa = endControl.value.trim().substring(6,10);
      String mm = endControl.value.trim().substring(3,5);
      String jj = endControl.value.trim().substring(0,2);
      String dstr = aaaa+"-"+mm+"-"+jj;
      try {
        todoItem.end = DateTime.parse(dstr);
      }
      catch (exception) {
        print("error parsing date "+dstr);
      }
    }
  }


}



