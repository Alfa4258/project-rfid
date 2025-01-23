import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'dart:typed_data';
import 'background_provider.dart';
import 'home_page.dart';
import 'rfid_check_page.dart';
import 'race_result_page.dart';
import 'upload_excel.dart';
import 'connection_provider.dart';

enum ConnectionType { RS232, TCPIP }

class ChangeBackgroundPage extends StatefulWidget {
  @override
  ChangeBackgroundPageState createState() => ChangeBackgroundPageState();
}

class ChangeBackgroundPageState extends State<ChangeBackgroundPage> with SingleTickerProviderStateMixin {
  File? _homeBannerImage;
  File? _displayBackgroundImage;

  // RFID Connection Settings
  ConnectionType _currentConnectionType = ConnectionType.RS232;
  String? _selectedPort;
  List<String> _availablePorts = [];
  String _ipAddress = '192.168.1.200';
  int _port = 2022;
  int _baudRate = 115200;
  bool _isConnected = false;

  SerialPort? _serialPort;
  SerialPortReader? _portReader;
  Socket? _socket;
  String connectionStatus = "Disconnected";

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _updateAvailablePorts();
    _loadConnectionSettings();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _disconnectRfidReader();
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    setState(() {
      _currentConnectionType = (_tabController.index == 0)
          ? ConnectionType.RS232
          : ConnectionType.TCPIP;
    });
  }

  void _handleConnect() async {
    bool connectionSuccessful = false;
    if (_currentConnectionType == ConnectionType.RS232) {
      if (_selectedPort == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a COM port')),
        );
        return;
      }
      connectionSuccessful = await _configureSerialPort();
    } else {
      connectionSuccessful = await _connectToRfidScannerTCP();
    }
    
    if (connectionSuccessful) {
      setState(() {
        _isConnected = true;
      });
      
      // Save settings immediately after successful connection
      final connectionSettingsProvider = Provider.of<ConnectionSettingsProvider>(context, listen: false);
      connectionSettingsProvider.setConnectionSettings(
        _currentConnectionType == ConnectionType.RS232 ? "RS232" : "TCP/IP",
        _selectedPort,
        _ipAddress,
        _port,
        _baudRate,
      );
    }
  }

  void _handleDisconnect() {
    _disconnectRfidReader();
    setState(() {
      _isConnected = false;
    });
  }

  Future<bool> _configureSerialPort() async {
    if (_selectedPort == null) {
      _updateConnectionStatus("No port selected");
      return false;
    }

    try {
      _serialPort = SerialPort(_selectedPort!);
      _serialPort!.config = SerialPortConfig()..baudRate = _baudRate;

      if (_serialPort!.openReadWrite()) {
        _updateConnectionStatus("Connected to RFID reader (RS232)");
        _portReader = SerialPortReader(_serialPort!);
        _portReader!.stream.listen(
          _handleSerialPortData,
          onError: (error) {
            print("RS232 Error: $error");
            _updateConnectionStatus("RS232 Error: $error");
          },
          onDone: () {
            _updateConnectionStatus("RS232 connection closed");
          },
        );
        return true;
      } else {
        _updateConnectionStatus("Failed to open RS232 port");
        return false;
      }
    } catch (e) {
      _updateConnectionStatus("RS232 Error: $e");
      return false;
    }
  }

  Future<bool> _connectToRfidScannerTCP() async {
    try {
      _socket = await Socket.connect(_ipAddress, _port);
      _updateConnectionStatus("Connected to RFID reader (TCP/IP)");

      _socket!.listen(
        _handleSocketData,
        onDone: () => _disconnectSocket("TCP/IP connection closed by server"),
        onError: (error) => _disconnectSocket("TCP/IP Error: $error"),
      );
      return true;
    } catch (e) {
      _updateConnectionStatus("TCP/IP connection failed: $e");
      return false;
    }
  }

  void _disconnectRfidReader() {
    if (_currentConnectionType == ConnectionType.RS232) {
      _disconnectSerialPort();
    } else {
      _disconnectSocket();
    }
  }

  void _disconnectSerialPort() {
    _portReader?.close();
    _serialPort?.close();
    _serialPort = null;
    _updateConnectionStatus("RS232 connection disconnected");
  }

  void _disconnectSocket([String message = "TCP/IP connection disconnected"]) {
    _socket?.destroy();
    _socket = null;
    _updateConnectionStatus(message);
  }

  void _handleSerialPortData(Uint8List data) {
    final receivedData = String.fromCharCodes(data);
    print("RS232 Data Received: $receivedData");
  }

  void _handleSocketData(List<int> data) {
    final receivedData = String.fromCharCodes(data);
    print("TCP/IP Data Received: $receivedData");
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
    });
  }

  void _loadConnectionSettings() {
    final settings = Provider.of<ConnectionSettingsProvider>(context, listen: false);
    setState(() {
      _currentConnectionType = settings.connectionType == 'RS232'
          ? ConnectionType.RS232
          : ConnectionType.TCPIP;
      _selectedPort = settings.selectedPort;
      _ipAddress = settings.ipAddress;
      _port = settings.port;
      _baudRate = settings.baudRate;
    });
  }

  Future<void> _pickImage(bool isHomeBanner) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.path != null) {
      setState(() {
        if (isHomeBanner) {
          _homeBannerImage = File(result.files.single.path!);
        } else {
          _displayBackgroundImage = File(result.files.single.path!);
        }
      });
    }
  }

  void _applySettings(BuildContext context) {
    final backgroundProvider = Provider.of<BackgroundProvider>(context, listen: false);
    if (_homeBannerImage != null) {
      backgroundProvider.setHomeBannerImage(_homeBannerImage);
    }
    if (_displayBackgroundImage != null) {
      backgroundProvider.setDisplayBackgroundImage(_displayBackgroundImage);
    }

    final connectionSettingsProvider = Provider.of<ConnectionSettingsProvider>(context, listen: false);
    connectionSettingsProvider.setConnectionSettings(
      _currentConnectionType == ConnectionType.RS232 ? "RS232" : "TCP/IP",
      _selectedPort,
      _ipAddress,
      _port,
      _baudRate,
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BackgroundProvider>(context);
    _homeBannerImage ??= provider.homeBannerImage;
    _displayBackgroundImage ??= provider.displayBackgroundImage;

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
              Image.asset('assets/logo.png', height: 40),
              SizedBox(width: 10),
              Text(
                'Labsco Sport',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              icon: Icon(Icons.menu, color: Colors.black),
              onSelected: (value) async {
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
                    MaterialPageRoute(
                        builder: (context) => ChangeBackgroundPage()),
                  );
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                    value: 'Home',
                    child: ListTile(
                        leading: Icon(Icons.home), title: Text('Home'))),
                PopupMenuItem<String>(
                    value: 'RFID Tag Check',
                    child: ListTile(
                        leading: Icon(Icons.info),
                        title: Text('RFID Tag Check'))),
                PopupMenuItem<String>(
                    value: 'Race Result',
                    child: ListTile(
                        leading: Icon(Icons.insert_chart_outlined),
                        title: Text('Race Result'))),
                PopupMenuItem<String>(
                    value: 'Upload Excel',
                    child: ListTile(
                        leading: Icon(Icons.upload_file),
                        title: Text('Upload Excel'))),
                PopupMenuItem<String>(
                    value: 'Display Settings',
                    child: ListTile(
                        leading: Icon(Icons.settings),
                        title: Text('Display Settings'))),
              ],
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Home Banner Image',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                if (_homeBannerImage != null)
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: FileImage(_homeBannerImage!),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  )
                else
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'No home banner selected',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ),
                  ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _pickImage(true),
                  child: Text('Pick Home Banner Image'),
                ),
                SizedBox(height: 40),
                Text(
                  'Display Background Image',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                if (_displayBackgroundImage != null)
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: FileImage(_displayBackgroundImage!),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  )
                else
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'No display background selected',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ),
                  ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _pickImage(false),
                  child: Text('Pick Display Background Image'),
                ),
                SizedBox(height: 40),
                Text(
                  'RFID Connection Settings',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Connect to RFID Reader',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Choose connection type and configure settings',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        TabBar(
                          controller: _tabController,
                          tabs: [
                            Tab(text: 'Connect Via RS232'),
                            Tab(text: 'Connect Via TCP/IP'),
                          ],
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Connection Status: ${_isConnected ? "Connected" : "Disconnected"}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _isConnected ? Colors.green : Colors.red,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  DropdownButton<String>(
                                    value: _selectedPort,
                                    items: _availablePorts.map((String port) {
                                      return DropdownMenuItem<String>(
                                        value: port,
                                        child: Text(port),
                                      );
                                    }).toList(),
                                    onChanged: _isConnected ? null : (String? newValue) {
                                      setState(() {
                                        _selectedPort = newValue;
                                      });
                                    },
                                    hint: Text('Select COM Port'),
                                  ),
                                  SizedBox(height: 16),
                                  TextFormField(
                                    initialValue: _baudRate.toString(),
                                    decoration: InputDecoration(labelText: 'Baud Rate'),
                                    keyboardType: TextInputType.number,
                                    onChanged: _isConnected
                                        ? null
                                        : (value) {
                                            setState(() {
                                              _baudRate = int.tryParse(value) ?? 115200;
                                            });
                                          },
                                  ),
                                  SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _isConnected ? _handleDisconnect : _handleConnect,
                                    child: Text(_isConnected ? "Disconnect" : "Connect via RS232"),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextFormField(
                                    initialValue: _ipAddress,
                                    decoration: InputDecoration(labelText: 'IP Address'),
                                    onChanged: _isConnected
                                        ? null
                                        : (value) {
                                            setState(() {
                                              _ipAddress = value;
                                            });
                                          },
                                  ),
                                  SizedBox(height: 16),
                                  TextFormField(
                                    initialValue: _port.toString(),
                                    decoration: InputDecoration(labelText: 'Port'),
                                    keyboardType: TextInputType.number,
                                    onChanged: _isConnected
                                        ? null
                                        : (value) {
                                            setState(() {
                                              _port = int.tryParse(value) ?? 2022;
                                            });
                                          },
                                  ),
                                  SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _isConnected ? _handleDisconnect : _handleConnect,
                                    child: Text(_isConnected ? "Disconnect" : "Connect via TCP/IP"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => _applySettings(context),
                  child: Text('Apply Settings'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}