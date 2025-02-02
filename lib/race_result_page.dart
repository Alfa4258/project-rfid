import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:provider/provider.dart';
import 'background_provider.dart';
import 'dart:typed_data';
import 'api_service.dart';
import 'home_page.dart';
import 'display_settings_page.dart';
import 'rfid_check_page.dart';
import 'display_race_result.dart';
import 'upload_excel.dart';
import 'db_helper.dart';

enum ConnectionType { RS232, TCPIP }

class RaceResultPage extends StatefulWidget {
  @override
  _RaceResultPageState createState() => _RaceResultPageState();
}

class _RaceResultPageState extends State<RaceResultPage> {
  final TextEditingController _bibController = TextEditingController();
  final ApiService _apiService = ApiService();

  SerialPort? _serialPort;
  SerialPortReader? _portReader;

  Socket? _socket;

  String connectionStatus = "Belum Terhubung";
  String rfidData = "Menunggu data...";
  String filteredRfidData = "Menunggu data...";

  Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(seconds: 1);
  bool _isProcessing = false;

  ConnectionType _currentConnectionType = ConnectionType.RS232;

  List<String> _availablePorts = [];
  String? _selectedPort;
  int _baudRate = 115200;

  @override
  void initState() {
    super.initState();
    _updateAvailablePorts();
  }

  @override
  void dispose() {
    _disconnectRfidReader();
    _bibController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _connectToRfidReader() async {
    if (_currentConnectionType == ConnectionType.RS232) {
      await _configureSerialPort();
    } else {
      await _connectToRfidScannerTCP();
    }
  }

  void _disconnectRfidReader() {
    if (_currentConnectionType == ConnectionType.RS232) {
      _disconnectSerialPort();
    } else {
      _disconnectSocket();
    }
  }

  Future<void> _configureSerialPort() async {
    if (_selectedPort == null) {
      _updateConnectionStatus("No port selected");
      return;
    }

    try {
      _serialPort = SerialPort(_selectedPort!);

      _serialPort!.config = SerialPortConfig()..baudRate = _baudRate;

      if (_serialPort!.openReadWrite()) {
        _updateConnectionStatus("Terhubung ke RFID reader (RS232)");
        _portReader = SerialPortReader(_serialPort!);
        _portReader!.stream.listen(
          _handleSerialPortData,
          onError: (error) {
            print("RS232 Error: $error");
            _updateConnectionStatus("Error RS232: $error");
          },
          onDone: () {
            print("RS232 connection closed");
            _updateConnectionStatus("Koneksi RS232 terputus");
          },
        );

        // Test the connection
        if (await _testConnection()) {
          print("RS232 connection test successful");
        } else {
          print("RS232 connection test failed");
          _updateConnectionStatus("RS232 connection test failed");
        }
      } else {
        print("Failed to open RS232 port");
        _updateConnectionStatus("Gagal membuka port RS232");
      }
    } catch (e) {
      print("RS232 Configuration Error: $e");
      _updateConnectionStatus("RS232 Error: $e");
    }
  }

  Future<bool> _testConnection() async {
    if (_serialPort == null || !_serialPort!.isOpen) {
      return false;
    }

    try {
      _serialPort!.write(Uint8List.fromList([0x10, 0x03, 0x01, 0x14]));

      await Future.delayed(Duration(seconds: 2));

      if (_portReader != null) {
        var data = await _portReader!.stream
            .first
            .timeout(Duration(seconds: 5), onTimeout: () => Uint8List(0));
        return data.isNotEmpty;
      }
    } catch (e) {
      print("Connection test error: $e");
    }

    return false;
  }

  void _disconnectSerialPort() {
    _portReader?.close();
    _serialPort?.close();
    _serialPort = null;
    _updateConnectionStatus("Koneksi RS232 terputus");
  }

  Future<void> _connectToRfidScannerTCP() async {
    if (_socket != null) return;

    try {
      _socket = await Socket.connect('192.168.1.200', 2022);
      _updateConnectionStatus("Terhubung ke RFID scanner (TCP/IP)");

      _socket!.listen(
        _handleSocketData,
        onDone: () => _disconnectSocket("Koneksi TCP/IP ditutup oleh server."),
        onError: (error) => _disconnectSocket("Error TCP/IP: $error"),
      );
    } catch (e) {
      _updateConnectionStatus("Koneksi TCP/IP gagal: $e");
    }
  }

  void _disconnectSocket([String message = "Koneksi TCP/IP terputus"]) {
    _socket?.destroy();
    _socket = null;
    _updateConnectionStatus(message);
  }

  void _handleSerialPortData(Uint8List data) {
    final hexData =
        data.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ');
    _processRfidData(hexData);
  }

  void _handleSocketData(List<int> event) {
    final hexData =
        event.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ');
    _processRfidData(hexData);
  }

  void _processRfidData(String hexData) {
    final extractedData = _extractSpecificData(hexData);

    setState(() {
      rfidData = hexData;
      filteredRfidData = extractedData;
      _bibController.text = extractedData;
    });

    _debouncedFetchBibDetails(extractedData);
  }

  String _extractSpecificData(String hexData) {
    final dataParts = hexData.split(' ');
    if (dataParts.length >= 23) {
      return "${dataParts[21]}${dataParts[22]}";
    }
    return "";
  }

  void _updateAvailablePorts() {
    setState(() {
      _availablePorts = SerialPort.availablePorts;
      if (_availablePorts.isNotEmpty && _selectedPort == null) {
        _selectedPort = _availablePorts.first;
      }
    });
  }

  void _updateConnectionStatus(String status) {
    setState(() {
      connectionStatus = status;
      if (status.contains("Belum Terhubung") ||
          status.contains("gagal") ||
          status.contains("Error")) {
        rfidData = "Menunggu data...";
        filteredRfidData = "Menunggu data...";
      }
    });
  }

  void _debouncedFetchBibDetails(String bibNumber) {
    if (_isProcessing) return;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      _fetchBibDetails(bibNumber);
    });
  }

Future<void> _fetchBibDetails(String bibNumber) async {
  if (_isProcessing) return;

  setState(() {
    _isProcessing = true;
  });

  try {
    final dbHelper = DatabaseHelper();

    // Ensure the database is initialized
    await dbHelper.database;  // This will ensure the database is fully initialized before performing any queries

    final raceResultsDetails = await dbHelper.getParticipant(bibNumber);

    if (raceResultsDetails != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RaceResultsDetailsPage(raceResultsDetails: raceResultsDetails),
        ),
      );
    } else {
      _showErrorDialog('BIB Number not found');
    }
  } catch (e) {
    _showErrorDialog('Error fetching BIB details: $e');
  } finally {
    setState(() {
      _isProcessing = false;
    });
  }
}

  void _toggleConnectionType() {
    _disconnectRfidReader();
    setState(() {
      _currentConnectionType = _currentConnectionType == ConnectionType.RS232
          ? ConnectionType.TCPIP
          : ConnectionType.RS232;
    });
    _connectToRfidReader();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundProvider = Provider.of<BackgroundProvider>(context);
    final File? backgroundImage = backgroundProvider.homeBannerImage;

    return Scaffold(
      backgroundColor: Color(0xFFCDC4C4),
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 30,
            ),
            SizedBox(width: 10),
            Text(
              'Labsco Sport',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                'RFID Race Result Check',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ),
          Container(
            width: 200,
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _bibController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                hintText: "Enter BIB Number",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              String bibNumber = _bibController.text.trim();
              _fetchBibDetails(bibNumber);
            },
            color: Colors.black,
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.menu, color: Colors.black),
            onSelected: (value) {
              if (value == 'Home') {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (route) => false,
                );
              } else if (value == 'RFID Tag Check') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RFIDTagCheckPage()),
                );
              } else if (value == 'Race Result') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RaceResultPage()),
                );
              } else if (value == 'Upload Excel') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExcelUploadPage()),
                );
              } else if (value == 'Display Settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangeBackgroundPage()),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'Home',
                child: ListTile(
                  leading: Icon(Icons.home),
                  title: Text('Home'),
                ),
              ),
              PopupMenuItem<String>(
                value: 'RFID Tag Check',
                child: ListTile(
                  leading: Icon(Icons.info),
                  title: Text('RFID Tag Check'),
                ),
              ),
              PopupMenuItem<String>(
                value: 'Race Result',
                child: ListTile(
                  leading: Icon(Icons.insert_chart_outlined_outlined),
                  title: Text('Race Result'),
                ),
              ),
              PopupMenuItem<String>(
                value: 'Upload Excel',
                child: ListTile(
                  leading: Icon(Icons.upload_file),
                  title: Text('Upload Excel'),
                ),
              ),
              PopupMenuItem<String>(
                value: 'Display Settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Display Settings'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: backgroundImage != null
              ? DecorationImage(
                  image: FileImage(backgroundImage),
                  fit: BoxFit.cover,
                )
              : null,
          color:
              backgroundImage == null ? Colors.grey[300] : Colors.transparent,
        ),
        child: backgroundImage == null
            ? Center(
                child: Text(
                  'No Background Available',
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
              )
            : null,
   ),
 );
}

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
