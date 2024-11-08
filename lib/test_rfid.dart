import 'dart:io';
import 'package:flutter/material.dart';

class RfidPage extends StatefulWidget {
  @override
  _RfidPageState createState() => _RfidPageState();
}

class _RfidPageState extends State<RfidPage> {
  Socket? _socket;
  String rfidData = "Menunggu data...";
  String connectionStatus = "Belum Terhubung";

  Future<void> connectToRfidScanner() async {
    if (_socket != null) {
      print("Sudah terhubung ke RFID scanner.");
      return;
    }

    try {
      final serverAddress = '192.168.1.200'; // IP 
      final serverPort = 2022; // Port 

      _socket = await Socket.connect(serverAddress, serverPort);
      setState(() {
        connectionStatus = "Terhubung ke RFID scanner";
      });
      print(connectionStatus);

      _socket!.listen((List<int> event) {
        // Decode the data safely by converting to a hexadecimal string
        String hexData = event.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ');
        
        setState(() {
          rfidData = hexData; // Display raw data as hex string
        });
      }, onDone: () {
        disconnectSocket("Koneksi ditutup oleh server.");
      }, onError: (error) {
        disconnectSocket("Error: $error");
      });
    } catch (e) {
      print('Gagal terhubung: $e');
      setState(() {
        connectionStatus = "Koneksi gagal";
        rfidData = "Koneksi gagal: $e";
      });
    }
  }

  // Fungsi untuk menutup koneksi
  void disconnectSocket([String? message]) {
    _socket?.destroy();
    _socket = null;
    setState(() {
      connectionStatus = message ?? "Koneksi terputus";
      rfidData = "Menunggu data...";
    });
  }

  @override
  void initState() {
    super.initState();
    connectToRfidScanner();
  }

  @override
  void dispose() {
    disconnectSocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("RFID Scanner"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              connectionStatus,
              style: TextStyle(
                fontSize: 18,
                color: connectionStatus == "Terhubung ke RFID scanner" ? Colors.green : Colors.red,
              ),
            ),
            SizedBox(height: 20),
            Text('Data RFID (Hex):', style: TextStyle(fontSize: 20)),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                rfidData,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                disconnectSocket();
                connectToRfidScanner();
              },
              child: Text('Coba Koneksi Ulang'),
            ),
          ],
        ),
      ),
    );
  }
}
