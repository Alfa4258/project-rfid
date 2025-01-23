import 'package:flutter/foundation.dart';

class ConnectionSettingsProvider with ChangeNotifier {
  String _connectionType = 'RS232';
  String? _selectedPort;
  String _ipAddress = '192.168.1.200';
  int _port = 2022;
  int _baudRate = 115200;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  void setConnectionStatus(bool status) {
    _isConnected = status;
    notifyListeners();
  }

  String get connectionType => _connectionType;
  String? get selectedPort => _selectedPort;
  String get ipAddress => _ipAddress;
  int get port => _port;
  int get baudRate => _baudRate;

  void setConnectionSettings(String connectionType, String? selectedPort, String ipAddress, int port, int baudRate) {
    _connectionType = connectionType;
    _selectedPort = selectedPort;
    _ipAddress = ipAddress;
    _port = port;
    _baudRate = baudRate;
    notifyListeners();
  }
}