import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'rfid_check_page.dart';
import 'display_settings_page.dart';
import 'race_result_page.dart';
import 'home_page.dart';

class ExcelUploadPage extends StatefulWidget {
  @override
  _ExcelUploadPageState createState() => _ExcelUploadPageState();
}

class _ExcelUploadPageState extends State<ExcelUploadPage> {
  File? _selectedFile;
  bool _isUploading = false;
  String _uploadStatus = '';

  // Function to pick an Excel file
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xls', 'xlsx'],
    );
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _uploadStatus = 'File selected: ${_selectedFile!.path.split('/').last}';
      });
    } else {
      setState(() {
        _uploadStatus = 'No file selected.';
      });
    }
  }

  // Function to upload the selected file to the API
  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;

    setState(() {
      _isUploading = true;
      _uploadStatus = 'Uploading...';
    });
    
    var uri = Uri.parse('http://127.0.0.1:8000/api/upload-db');
    var request = http.MultipartRequest('POST', uri);

    // Attach the file
    request.files.add(await http.MultipartFile.fromPath('file', _selectedFile!.path));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        setState(() {
          _uploadStatus = 'File uploaded successfully!';
        });
      } else {
        setState(() {
          _uploadStatus = 'File upload failed with status: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _uploadStatus = 'Error uploading file: $e';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // Function to navigate to HomePage when back button is pressed
  Future<bool> _onWillPop() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
      (route) => false,
    );
    return false;  // Prevents the default back navigation
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Color(0xFFCDC4C4),
        appBar: AppBar(
          backgroundColor: Colors.grey[200],
          elevation: 0,
          title: Row(
            children: [
              Image.asset(
                'assets/logo.png',  // Replace with your logo asset
                height: 40,
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
                  final pickedImage = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChangeBackgroundPage()),
                  );
                  if (pickedImage != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(backgroundImage: pickedImage),
                      ),
                    );
                  }
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
          child: Container(
            margin: EdgeInsets.all(20),
            height: 600,
            width: MediaQuery.of(context).size.width * 0.8,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Select an Excel file to upload:',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickFile,
                  child: Text('Choose Excel File'),
                ),
                SizedBox(height: 10),
                if (_selectedFile != null) 
                  Text(
                    'Selected file: ${_selectedFile!.path.split('/').last}',
                    style: TextStyle(fontSize: 16),
                  ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isUploading ? null : _uploadFile,
                  child: _isUploading 
                      ? CircularProgressIndicator() 
                      : Text('Upload File'),
                ),
                SizedBox(height: 20),
                Text(
                  _uploadStatus,
                  style: TextStyle(color: Colors.green, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
