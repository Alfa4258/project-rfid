import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'db_helper.dart';
import 'excel_helper.dart';
import 'home_page.dart';
import 'race_result_page.dart';
import 'rfid_check_page.dart';
import 'display_settings_page.dart';

class ExcelUploadPage extends StatefulWidget {
  @override
  _ExcelUploadPageState createState() => _ExcelUploadPageState();
}

class _ExcelUploadPageState extends State<ExcelUploadPage> {
  File? _selectedFile;
  bool _isUploading = false;
  String _uploadStatus = '';
  List<Map<String, dynamic>> _participants = [];

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

  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;

    setState(() {
      _isUploading = true;
      _uploadStatus = 'Uploading...';
    });

    try {
      // Parse Excel file
      List<Map<String, dynamic>> parsedData =
          await parseExcelFile(_selectedFile!);

      // Update database
      await DatabaseHelper().updateDatabaseFromExcel(parsedData);

      setState(() {
        _uploadStatus = 'Database updated successfully!';
      });

      await _fetchParticipants(); // Refresh the participant list
    } catch (e) {
      setState(() {
        _uploadStatus = 'Error updating database: $e';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _fetchParticipants() async {
    List<Map<String, dynamic>> participants =
        await DatabaseHelper().getAllParticipants();
    setState(() {
      _participants = participants;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchParticipants(); // Load participants on start
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFCDC4C4), // Set background color here
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 30),
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
              } else if (value == 'Settings') {
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
                  child:
                      ListTile(leading: Icon(Icons.home), title: Text('Home'))),
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
                  value: 'Settings',
                  child: ListTile(
                      leading: Icon(Icons.settings), title: Text('Settings'))),
            ],
          ),
        ],
      ),
     body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _pickFile,
                    child: Text('Choose Excel File'),
                  ),
                  SizedBox(height: 10),
                  if (_selectedFile != null)
                    Text('Selected file: ${_selectedFile!.path.split('/').last}'),
                  SizedBox(height: 15), // Reduced this gap
                  ElevatedButton(
                    onPressed: _isUploading ? null : _uploadFile,
                    child: _isUploading
                        ? CircularProgressIndicator()
                        : Text('Upload and Update Database'),
                  ),
                  SizedBox(height: 15), // Reduced this gap
                  Text(
                    _uploadStatus,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height:90), // Smaller spacing
                ],
              ),
            ),
          ),
          if (_uploadStatus == 'Database updated successfully!')
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Uploaded Participants:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black),
                    ),
                    SizedBox(height: 5), // Reduced this gap
                    Expanded(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: Scrollbar(
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columnSpacing: 20,
                                  headingRowColor:
                                      MaterialStateColor.resolveWith(
                                          (states) => Colors.grey[300]!),
                                  dataRowColor: MaterialStateColor.resolveWith(
                                      (states) =>
                                          states.contains(MaterialState.selected)
                                              ? Colors.blue[100]!
                                              : Colors.white),
                                  border: TableBorder.all(
                                      color: Colors.grey[400]!, width: 1),
                                  columns: const <DataColumn>[
                                    DataColumn(
                                        label: Text(
                                      'First Name',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    )),
                                    DataColumn(
                                        label: Text(
                                      'Last Name',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    )),
                                    DataColumn(
                                        label: Text(
                                      'BIB Number',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    )),
                                    
                                  ],
                                  rows: _participants
                                      .map((participant) => DataRow(
                                            cells: [
                                              DataCell(Text(
                                                  participant['first_name'],
                                                  style: TextStyle(
                                                      fontSize: 14))),
                                              DataCell(Text(
                                                  participant['last_name'],
                                                  style: TextStyle(
                                                      fontSize: 14))),
                                              DataCell(Text(
                                                  participant['bib_number']
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 14))),
                                            ],
                                          ))
                                      .toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
