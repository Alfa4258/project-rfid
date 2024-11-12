import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'api_service.dart';  
import 'home_page.dart';   
import 'display_settings_page.dart';  
import 'rfid_check_page.dart'; 
import 'display_race_result.dart';
import 'upload_excel.dart';

class RaceResultPage extends StatefulWidget {
  @override
  _RaceResultPageState createState() => _RaceResultPageState();
}

class _RaceResultPageState extends State<RaceResultPage> {
  final TextEditingController _bibController = TextEditingController();
  final ApiService _apiService = ApiService(); 
  Socket? _socket;

  String connectionStatus = "Belum Terhubung";
  String rfidData = "Menunggu data...";
  String filteredRfidData = "Menunggu data...";

  Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(seconds: 1);
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _connectToRfidScanner();
  }

  @override
  void dispose() {
    _disconnectSocket();
    _bibController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

    Future<void> _connectToRfidScanner() async {
    if (_socket != null) return;

    try {
      _socket = await Socket.connect('192.168.1.200', 2022);
      _updateConnectionStatus("Terhubung ke RFID scanner");

      _socket!.listen(
        _handleSocketData,
        onDone: () => _disconnectSocket("Koneksi ditutup oleh server."),
        onError: (error) => _disconnectSocket("Error: $error"),
      );
    } catch (e) {
      _updateConnectionStatus("Koneksi gagal: $e");
    }
  }

    void _disconnectSocket([String message = "Koneksi terputus"]) {
    _socket?.destroy();
    _socket = null;
    _updateConnectionStatus(message);
  }

  void _updateConnectionStatus(String status) {
    setState(() {
      connectionStatus = status;
      if (status != "Terhubung ke RFID scanner") {
        rfidData = "Menunggu data...";
        filteredRfidData = "Menunggu data...";
      }
    });
  }

  void _handleSocketData(List<int> event) {
    final hexData =
        event.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ');
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
    return "${dataParts[21]}${dataParts[22]}";
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
      final bibDetails = await _apiService.fetchBibDetails(bibNumber);
      if (bibDetails != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RaceResultsDetailsPage(raceResultsDetails: bibDetails)),
        );
      } else {
        _showErrorDialog('BIB Number not found');
      }
    } catch (_) {
      _showErrorDialog('Error fetching BIB details');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
          (route) => false, 
        );
        return false; 
      },
      child: Scaffold(
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
                  'RFID Tag Check',
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
                    (route) => false, // Navigate to the home screen
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
                }else if (value == 'Upload Excel') {
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_tethering, size: 100, color: Colors.black54,),
              SizedBox(height: 20),
              Text(
                connectionStatus,
                style: TextStyle(
                  fontSize: 18,
                  color: connectionStatus == "Terhubung ke RFID scanner"
                      ? Colors.green
                      : Colors.red,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Data RFID (Hex): $rfidData',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              SizedBox(height: 10),
              Text(
                'Filtered Data: $filteredRfidData',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ],
          ),
        ),
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
