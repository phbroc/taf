import 'package:angular/angular.dart';
import 'dart:async';
import 'dart:html';

@Injectable()
class EventBus {

  final StreamController<Event> _onEventStreamLog = StreamController<Event>();
  Stream<Event> onEventStreamLog = null;

  final StreamController<String> _onEventStreamTodoAdd = StreamController<String>.broadcast();
  Stream<String> onEventStreamTodoAdd = null;

  static final EventBus _singleton = EventBus._internal();

  factory EventBus() {
    return _singleton;
  }

  EventBus._internal() {
    onEventStreamLog = _onEventStreamLog.stream;
    onEventStreamTodoAdd = _onEventStreamTodoAdd.stream;
  }

  onEventLog(Event event) {
    _onEventStreamLog.add(event);
  }

  onEventTodoAdd(String s) {
    _onEventStreamTodoAdd.add(s);
  }
}