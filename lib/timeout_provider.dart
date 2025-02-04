import 'package:flutter/foundation.dart';

class TimeoutProvider with ChangeNotifier {
  int _timeoutDuration = 10; // Default to 10 seconds
  int _tempTimeoutDuration = 10; // Temporary value for the slider

  int get timeoutDuration => _timeoutDuration;
  int get tempTimeoutDuration => _tempTimeoutDuration;

  void setTempTimeoutDuration(int duration) {
    // Round to nearest 5 seconds
    int roundedDuration = (duration / 5).round() * 5;

    // Ensure the value is within our 5-60 second range
    roundedDuration = roundedDuration.clamp(5, 60);

    if (roundedDuration != _tempTimeoutDuration) {
      _tempTimeoutDuration = roundedDuration;
      notifyListeners();
    }
  }

  void applyTimeoutDuration() {
    if (_tempTimeoutDuration != _timeoutDuration) {
      _timeoutDuration = _tempTimeoutDuration;
      notifyListeners();
    }
  }
}
