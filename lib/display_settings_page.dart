import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'rfid_check_page.dart';
import 'home_page.dart'; // Make sure to import the HomePage
import 'dart:io';

class ChangeBackgroundPage extends StatefulWidget {
  @override
  ChangeBackgroundPageState createState() => ChangeBackgroundPageState();
}

class ChangeBackgroundPageState extends State<ChangeBackgroundPage> {
  File? _backgroundImage;

  Future<void> _pickBackgroundImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _backgroundImage = File(result.files.single.path!);
      });
    }
  }

  void _applyBackground() {
    // Navigate to HomePage and remove all previous routes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage(backgroundImage: _backgroundImage)), // Pass the selected image to HomePage
      (route) => false, // Remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // This will navigate to HomePage when the back button is pressed
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage(backgroundImage: _backgroundImage)),
          (route) => false, // Remove all routes until HomePage
        );
        return false; // Prevent the default back action
      },
      child: Scaffold(
        backgroundColor: Color(0xFFCDC4C4), // Set the background color to match the dashboard
        appBar: AppBar(
          backgroundColor: Colors.grey[200],
          title: Row(
            children: [
              Image.asset(
                'assets/logo.png', // Replace with your logo asset
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
              onSelected: (value) {
                if (value == 'Home') {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage(backgroundImage: _backgroundImage)),
                    (route) => false, // Navigate to the home screen
                  ); 
                } else if (value == 'RFID Tag Check') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RFIDTagCheckPage()),
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
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_backgroundImage != null)
              Center(  // Center widget to position the container in the middle
                child: Container(
                  height: 700,  // Fixed height for the container
                  width: 700,  // Fixed width for the container
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(_backgroundImage!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 300,
                color: Colors.grey[300], // Default background if no image is selected
                child: Center(
                  child: Text(
                    'No background selected',
                    style: TextStyle(fontSize: 20, color: Colors.black54),
                  ),
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickBackgroundImage,
              child: Text('Pick Image'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _applyBackground,
              child: Text('Apply Background'),
            ),
          ],
        ),
      ),
    );
  }
}
