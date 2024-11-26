import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'background_provider.dart';
import 'home_page.dart';
import 'rfid_check_page.dart';
import 'race_result_page.dart';
import 'upload_excel.dart';

class ChangeBackgroundPage extends StatefulWidget {
  @override
  ChangeBackgroundPageState createState() => ChangeBackgroundPageState();
}

class ChangeBackgroundPageState extends State<ChangeBackgroundPage> {
  File? _homeBannerImage;
  File? _displayBackgroundImage;

  Future<void> _pickImage(bool isHomeBanner) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

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

  void _applyBackgrounds(BuildContext context) {
    final provider = Provider.of<BackgroundProvider>(context, listen: false);
    if (_homeBannerImage != null) {
      provider.setHomeBannerImage(_homeBannerImage);
    }
    if (_displayBackgroundImage != null) {
      provider.setDisplayBackgroundImage(_displayBackgroundImage);
    }

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
                ElevatedButton(
                  onPressed: () => _applyBackgrounds(context),
                  child: Text('Apply Backgrounds'),
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
