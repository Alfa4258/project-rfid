import 'package:flutter/foundation.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';

class ConnectionSettingsProvider with ChangeNotifier {
  String _connectionType = 'RS232';
  String? _selectedPort;
  String _ipAddress = '192.168.1.200';
  int _port = 2022;
  int _baudRate = 115200;
  bool _isConnected = false;

  SerialPort? _serialPort;
  StreamSubscription<Uint8List>? _portSubscription;
  Socket? _socket;

  Function(Uint8List)? _onDataReceived;

  bool get isConnected => _isConnected;
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

  Future<bool> connect() async {
    if (_isConnected) return true;

    bool success = false;
    if (_connectionType == 'RS232') {
      success = await _connectSerialPort();
    } else {
      success = await _connectTCP();
    }

    _isConnected = success;
    notifyListeners();
    return success;
  }

  Future<bool> _connectSerialPort() async {
    if (_selectedPort == null) return false;

    try {
      _serialPort = SerialPort(_selectedPort!);
      _serialPort!.config = SerialPortConfig()..baudRate = _baudRate;

      if (_serialPort!.openReadWrite()) {
        final reader = SerialPortReader(_serialPort!);
        _portSubscription = reader.stream.listen(
          (data) {
            if (_onDataReceived != null) {
              _onDataReceived!(data);
            }
          },
          onError: (error) {
            print("RS232 Error: $error");
            disconnect();
          },
          onDone: () {
            disconnect();
          },
        );
        return true;
      }
    } catch (e) {
      print("RS232 Error: $e");
      _cleanup();
    }
    return false;
  }

  Future<bool> _connectTCP() async {
    try {
      _socket = await Socket.connect(_ipAddress, _port);
      _socket!.listen(
        (data) {
          if (_onDataReceived != null) {
            _onDataReceived!(Uint8List.fromList(data));
          }
        },
        onError: (error) {
          print("TCP Error: $error");
          disconnect();
        },
        onDone: () {
          disconnect();
        },
      );
      return true;
    } catch (e) {
      print("TCP Error: $e");
      _cleanup();
    }
    return false;
  }

  void disconnect() {
    _cleanup();
    _isConnected = false;
    notifyListeners();
  }

  void _cleanup() {
    _portSubscription?.cancel();
    _serialPort?.close();
    _socket?.destroy();
    _serialPort = null;
    _portSubscription = null;
    _socket = null;
    _onDataReceived = null;
  }

  void setDataCallback(Function(Uint8List) callback) {
    _onDataReceived = callback;
  }
}