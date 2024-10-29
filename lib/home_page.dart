import 'package:flutter/material.dart';
import 'dart:io';
import 'rfid_check_page.dart';
import 'display_settings_page.dart';
import 'race_result_page.dart';

class HomePage extends StatelessWidget {
  final File? backgroundImage;  // File for the background image

  HomePage({this.backgroundImage});  // Constructor accepts the background image

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFCDC4C4),  // Default background color
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,  // Flat look for the AppBar
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
                Navigator.popUntil(context, (route) => route.isFirst);  // Navigate to the home screen
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
              } else if (value == 'Display Settings') {
                final pickedImage = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangeBackgroundPage()),
                );

                if (pickedImage != null) {
                  // Reload HomePage with the selected background image
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
          height: 900,  // Fixed height for the container
          width: MediaQuery.of(context).size.width * 1.5,  // Width set to 80% of screen width
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            // Show the background image if it's provided, otherwise fallback to default background color
            image: backgroundImage != null 
                ? DecorationImage(
                    image: FileImage(backgroundImage!),
                    fit: BoxFit.cover,  // Fit image to cover the container
                  )
                : null,
            color: backgroundImage == null ? Colors.grey[300] : Colors.transparent,
          ),
          child: backgroundImage == null 
              ? Center(  // Default message when no background image is set
                  child: Text(
                    'No Background Available',
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
