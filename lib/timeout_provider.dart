import 'package:flutter/foundation.dart';

class TimeoutProvider with ChangeNotifier {
  int _timeoutDuration = 10; // Default to 10 seconds

  int get timeoutDuration => _timeoutDuration;

  void setTimeoutDuration(int duration) {
    if (duration != _timeoutDuration) {
      _timeoutDuration = duration;
      notifyListeners();
    }
  }
}
