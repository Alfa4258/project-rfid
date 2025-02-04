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
import 'timeout_provider.dart';

enum ConnectionType { RS232, TCPIP }

class ChangeBackgroundPage extends StatefulWidget {
  @override
  ChangeBackgroundPageState createState() => ChangeBackgroundPageState();
}

class ChangeBackgroundPageState extends State<ChangeBackgroundPage>
    with SingleTickerProviderStateMixin {
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
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadConnectionSettings();
      _updateAvailablePorts();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateConnectionStatus();
  }

  @override
  void dispose() {
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

  void _updateConnectionStatus() {
    final provider = Provider.of<ConnectionSettingsProvider>(context, listen: false);
    setState(() {
      connectionStatus = provider.isConnected ? "Connected to RFID reader (${provider.connectionType})" : "Disconnected";
    });
  }

  void _handleConnect() async {
    final provider = Provider.of<ConnectionSettingsProvider>(context, listen: false);

    provider.setConnectionSettings(
      _currentConnectionType == ConnectionType.RS232 ? "RS232" : "TCP/IP",
      _selectedPort,
      _ipAddress,
      _port,
      _baudRate,
    );

    await provider.connect();
  }

  void _handleDisconnect() {
    final provider = Provider.of<ConnectionSettingsProvider>(context, listen: false);
    provider.disconnect();
  }

  Future<void> _configureSerialPort() async {
    if (_selectedPort == null) return;

    final provider = Provider.of<ConnectionSettingsProvider>(context, listen: false);
    await provider.connect();
  }

  Future<void> _connectToRFIDScannerTCP() async {
    final provider = Provider.of<ConnectionSettingsProvider>(context, listen: false);
    await provider.connect();
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
  }

  void _disconnectSocket([String message = "TCP/IP connection disconnected"]) {
    _socket?.destroy();
    _socket = null;
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
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

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
    final backgroundProvider =
        Provider.of<BackgroundProvider>(context, listen: false);
    if (_homeBannerImage != null) {
      backgroundProvider.setHomeBannerImage(_homeBannerImage);
    }
    if (_displayBackgroundImage != null) {
      backgroundProvider.setDisplayBackgroundImage(_displayBackgroundImage);
    }

    final connectionSettingsProvider =
        Provider.of<ConnectionSettingsProvider>(context, listen: false);
    connectionSettingsProvider.setConnectionSettings(
      _currentConnectionType == ConnectionType.RS232 ? "RS232" : "TCP/IP",
      _selectedPort,
      _ipAddress,
      _port,
      _baudRate,
    );

    // Apply the timeout duration
    final timeoutProvider =
        Provider.of<TimeoutProvider>(context, listen: false);
    timeoutProvider.applyTimeoutDuration();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
      (route) => false,
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
                Consumer<TimeoutProvider>(
                  builder: (context, timeoutProvider, child) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Display Timeout (seconds):',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Slider(
                            value:
                                timeoutProvider.tempTimeoutDuration.toDouble(),
                            min: 5,
                            max: 60,
                            divisions: 11,
                            label:
                                timeoutProvider.tempTimeoutDuration.toString(),
                            onChanged: (value) {
                              timeoutProvider
                                  .setTempTimeoutDuration(value.round());
                            },
                          ),
                          Text(
                            'New timeout: ${timeoutProvider.tempTimeoutDuration} seconds',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Current timeout: ${timeoutProvider.timeoutDuration} seconds',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  },
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
                        Consumer<ConnectionSettingsProvider>(
                          builder: (context, provider, child) {
                            return Text(
                              provider.isConnected ? "Connected to RFID reader" : "Disconnected",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: provider.isConnected ? Colors.green : Colors.red,
                              ),
                            );
                          },
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
                                  DropdownButton<String>(
                                    value: _selectedPort,
                                    items: _availablePorts.map((String port) {
                                      return DropdownMenuItem<String>(
                                        value: port,
                                        child: Text(port),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
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
                                    onChanged: (value) {
                                      setState(() {
                                        _baudRate = int.tryParse(value) ?? 115200;
                                      });
                                    },
                                  ),
                                  SizedBox(height: 16),
                                  Consumer<ConnectionSettingsProvider>(
                                    builder: (context, provider, child) {
                                      return ElevatedButton(
                                        onPressed: provider.isConnected ? _handleDisconnect : _handleConnect,
                                        child: Text(provider.isConnected ? "Disconnect" : "Connect via RS232"),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextFormField(
                                    initialValue: _ipAddress,
                                    decoration: InputDecoration(labelText: 'IP Address'),
                                    onChanged: (value) {
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
                                    onChanged: (value) {
                                      setState(() {
                                        _port = int.tryParse(value) ?? 2022;
                                      });
                                    },
                                  ),
                                  SizedBox(height: 16),
                                  Consumer<ConnectionSettingsProvider>(
                                    builder: (context, provider, child) {
                                      return ElevatedButton(
                                        onPressed: provider.isConnected ? _handleDisconnect : _handleConnect,
                                        child: Text(provider.isConnected ? "Disconnect" : "Connect via TCP/IP"),
                                      );
                                    },
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
