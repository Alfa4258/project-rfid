import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'background_provider.dart';
import 'dart:typed_data';
import 'api_service.dart';
import 'display_bib.dart';
import 'home_page.dart';
import 'race_result_page.dart';
import 'upload_excel.dart';
import 'display_settings_page.dart';
import 'db_helper.dart';
import 'connection_provider.dart';

enum ConnectionType { RS232, TCPIP }

class RFIDTagCheckPage extends StatefulWidget {
  @override
  _RFIDTagCheckPageState createState() => _RFIDTagCheckPageState();
}

class _RFIDTagCheckPageState extends State<RFIDTagCheckPage> with SingleTickerProviderStateMixin {
  final _bibController = TextEditingController();
  final ApiService _apiService = ApiService();
  
  String connectionStatus = "Belum Terhubung";
  String rfidData = "Menunggu data...";
  String filteredRfidData = "Menunggu data...";

  Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(seconds: 1);
  bool _isProcessing = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
        WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeConnection();
    });
  }

  void _initializeConnection() {
    final provider = Provider.of<ConnectionSettingsProvider>(context, listen: false);
    if (provider.isConnected) {
      _setupDataListeners(provider);
      setState(() {
        connectionStatus = "Connected to RFID reader (${provider.connectionType})";
      });
    } else {
      provider.connect().then((success) {
        if (success) {
          _setupDataListeners(provider);
          setState(() {
            connectionStatus = "Connected to RFID reader (${provider.connectionType})";
          });
        } else {
          setState(() {
            connectionStatus = "Failed to connect";
          });
        }
      });
    }
  }

  void _setupDataListeners(ConnectionSettingsProvider provider) {
    provider.setDataCallback(_handleRfidData);
  }

  void _handleRfidData(Uint8List data) {
    final hexData = data.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ');
    _processRfidData(hexData);
  }

  @override
  void dispose() {
    _bibController.dispose();
    _debounceTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _handleSerialPortData(Uint8List data) {
    final hexData = data.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ');
    _processRfidData(hexData);
  }

  void _handleSocketData(List<int> event) {
    final hexData = event.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ');
    _processRfidData(hexData);
  }

  void _processRfidData(String hexData) {
    final extractedData = _extractSpecificData(hexData);

    setState(() {
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

  void _updateConnectionStatus(String status) {
    setState(() {
      connectionStatus = status;
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

    final bibDetails = await dbHelper.getParticipant(bibNumber);

    if (bibDetails != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BibDetailsPage(bibDetails: bibDetails),
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
}