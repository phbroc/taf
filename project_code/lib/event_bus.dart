import 'package:angular/angular.dart';
import 'dart:async';
import 'dart:html';

@Injectable()
class EventBus {

  final StreamController<Event> _onEventStreamLog = StreamController<Event>();
  Stream<Event> onEventStreamLog = null;

  final StreamController<String> _onEventStreamTodoAdded = StreamController<String>.broadcast();
  Stream<String> onEventStreamTodoAdded = null;

  final StreamController<String> _onEventStreamTodoChanged = StreamController<String>.broadcast();
  Stream<String> onEventStreamTodoChanged = null;

  static final EventBus _singleton = EventBus._internal();

  factory EventBus() {
    return _singleton;
  }

  EventBus._internal() {
    onEventStreamLog = _onEventStreamLog.stream;
    onEventStreamTodoAdded = _onEventStreamTodoAdded.stream;
    onEventStreamTodoChanged = _onEventStreamTodoChanged.stream;
  }

  onEventLog(Event event) {
    _onEventStreamLog.add(event);
  }

  onEventTodoAdded(String s) {
    _onEventStreamTodoAdded.add(s);
  }

  onEventTodoChanged(String s) {
    _onEventStreamTodoChanged.add(s);
  }
}