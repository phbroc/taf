import 'dart:async';

class MessageService {
  static StreamController doneController = StreamController.broadcast();

  static void send(String message) {
    doneController.add(message);
  }
}